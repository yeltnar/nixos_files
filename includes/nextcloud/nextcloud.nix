{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [ 8380 ];

  systemd.services.nextcloud-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "nextcloud-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/etc/yeltnar/nextcloud";
    };
    script = ''
      mkdir -p /etc/yeltnar/; 
      chmod 777 /etc/yeltnar/; 
      /run/wrappers/bin/su - drew -s /bin/sh -c 'cd /etc/yeltnar/; git clone https://github.com/yeltnar/nextcloud';
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "nextcloud";
      WorkingDirectory = "/tmp";
      ExecStartPost = "systemctl start nextcloud_start.service";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';
  systemd.services.nextcloud_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];

    script = ''
      # sleep 120; # sleep so it maybe has the files
      PATH="$PATH:/run/wrappers/bin/";
      ${pkgs.podman-compose}/bin/podman-compose up 2>&1 | tee /etc/yeltnar/nextcloud/podman-compose.log
    '';

    wantedBy = ["multi-user.target"];
    # If you use podman
    requires = ["podman.service" "podman.socket"];
    unitConfig = {
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/etc/yeltnar/nextcloud";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      User = "drew";
      # Type = "forking";
      WorkingDirectory = "/etc/yeltnar/nextcloud";
      Restart = "always";
    };
  };
}
