{
  config,
  pkgs,
  ...
}: 
let
  user = "drew";
  group = 100;
in {
  networking.firewall.allowedTCPPorts = [3000];

  systemd.services.vaultwarden_start-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "vaultwarden_start-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/tmp/vaultwarden_start";
    };
    script = ''
      /run/wrappers/bin/su - ${user} -s /bin/sh -c 'cd /tmp/; git clone https://github.com/yeltnar/vaultwarden_start';
      /run/wrappers/bin/su - ${user} -s /bin/sh -c 'cd /tmp/vaultwarden_start; echo "VAULTWARDEN_PATH=\"https://nixos.lan\"" > .env';
      mkdir /tmp/vaultwarden_start/vw-data;
      chown ${user}:${group} /tmp/vaultwarden_start/vw-data;
      chmod 777 /tmp/vaultwarden_start/vw-data;
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "vaultwarden_start";
      WorkingDirectory = "/tmp";
      ExecStartPost = "systemctl start vaultwarden_start_start.service";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';
  systemd.services.vaultwarden_start_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];

    script = ''
      # sleep 120; # sleep so it maybe has the files
      PATH="$PATH:/run/wrappers/bin/";
      ${pkgs.podman-compose}/bin/podman-compose up 2>&1 | tee /tmp/vaultwarden_start/podman-compose.log
    '';

    wantedBy = ["multi-user.target"];
    # If you use podman
    requires = ["podman.service" "podman.socket"];
    unitConfig = {
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/vaultwarden_start";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      # User = "drew";
      # Type = "forking";
      WorkingDirectory = "/tmp/vaultwarden_start";
      Restart = "always";
    };
  };
}
