{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [3000];

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
      ExecStartPost = "systemctl start wedding_site_start.service";
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

    script = ''
      # sleep 120; # sleep so it maybe has the files
      PATH="$PATH:/run/wrappers/bin/";
      ${pkgs.podman-compose}/bin/podman-compose up 2>&1 | tee /tmp/wedding_site/podman-compose.log
    '';

    wantedBy = ["multi-user.target"];
    # If you use podman
    requires = ["podman.service" "podman.socket"];
    unitConfig = {
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/wedding_site";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      User = "drew";
      # Type = "forking";
      WorkingDirectory = "/tmp/wedding_site";
      Restart = "always";
    };
  };
}
