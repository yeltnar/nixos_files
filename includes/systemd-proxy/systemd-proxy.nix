
{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [
  3000
  9999
  ];

# man systemd-socket-proxyd
  systemd.sockets.wedding_site_serverless = {
    requires = ["network-online.target"];
    listenStreams = [
      "9999"
      # "192.168.2.180:9999"
      # "8080"
    ];
    wantedBy = ["sockets.target"];
  };

  systemd.services.wedding_site_serverless = {
    requires = ["wedding_site_start.service" "wedding_site_serverless.socket"];
    after =    ["wedding_site_start.service" "wedding_site_serverless.socket"];

    serviceConfig = { 
      ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd --exit-idle-time=30s 127.0.0.1:3000";
    };

    # script = ''
    #   date > /tmp/proxyd-hit;
    #   ${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:3000;
    # '';
    
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
  systemd.services.wedding_site_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];

    # WARNING this process can not self re-start, or it will confuse the serverless aspect
    script = ''
      # sleep 120; # sleep so it maybe has the files
      PATH="$PATH:/nix/store/rhcdph69njf9ma4jyrzbm4by0jp5zn60-podman-5.0.3/bin";
      # /nix/store/6gi5l2cf6gpmg3skj5mc32xx454rnjwr-podman-compose-1.1.0/bin/podman-compose --podman-run-args="--replace --sdnotify=container --conmon-pidfile=/tmp/wedding_podman.pid --replace" up --no-recreate -d 2>&1 | tee /tmp/wedding_site/podman-compose.log
      /nix/store/6gi5l2cf6gpmg3skj5mc32xx454rnjwr-podman-compose-1.1.0/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/wedding_podman.pid --replace" up --no-recreate -d 2>&1 | tee /tmp/wedding_site/podman-compose.log
    '';

    # wantedBy = ["multi-user.target"];
    # If you use podman
    requires = ["podman.service" "podman.socket"];

    unitConfig = {
      StopWhenUnneeded = "yes";
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/wedding_site";
      RequiresMountsFor = "/run/user/1000/containers";
    };

    serviceConfig = {
      # User = "drew";
      Type = "notify";
      WorkingDirectory = "/tmp/wedding_site";
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/wedding_podman.pid";
      # ExecStop = ''
      #   kill -9 $MAINPID
      # '';
    };
  };
}
