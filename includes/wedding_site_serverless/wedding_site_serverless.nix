# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
  # 3000 # port for container
  # 8443 # port for user service  
  443 # port for system service
  ];

  # enable lingering so service starts before user logs in
  users.users.drew.linger = true;

  systemd.sockets.wedding_site_serverless = {
    requires = [
      "network-online.target"
      "default.target"
    ]; 
    wantedBy = [
      "default.target"
      "sockets.target"
      "multi-user.target"
    ];
    listenStreams = [
      "443"
    ];
  };

  systemd.services.wedding_site_serverless = {
    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=30s 127.0.0.1:8443";
    };
  };

  systemd.user.sockets.wedding_site_serverless = {
    requires = [
      # "network-online.target"
      "default.target"
    ]; # TODO make sure this is there, if starting at boot 
    wantedBy = [
      "default.target"
      "sockets.target"
      "multi-user.target"
    ];
    listenStreams = [
      "127.0.0.1:8443"
      # "192.168.2.180:9999"
      # "8080"
    ];
  };

  systemd.user.services.wedding_site_serverless = {
    requires = ["wedding_site_start.service" "wedding_site_serverless.socket"];
    after =    ["wedding_site_start.service" "wedding_site_serverless.socket"];

    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=30s 127.0.0.1:3000";
    };
  };

  systemd.services.wedding_site-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "wedding_site-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/tmp/wedding_site";
    };
    script = ''
      /run/wrappers/bin/su - drew -s /bin/sh -c 'cd /tmp/; git clone https://github.com/yeltnar/wedding_site';
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "wedding_site";
      WorkingDirectory = "/tmp";
      # ExecStartPost = "systemctl start wedding_site_start.service";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.user.services.wedding_site_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    requires = ["podman.service" "podman.socket"];
    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/wedding_podman.pid --replace" up --no-recreate -d 2>&1 | tee /tmp/wedding_site/podman-compose.log
    '';
    # wantedBy = ["multi-user.target"];
    unitConfig = {
      StopWhenUnneeded = "yes";
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/wedding_site";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "/tmp/wedding_site"; # TODO change repo location
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/wedding_podman.pid"; # TODO change pid location 
    };
  };
}
