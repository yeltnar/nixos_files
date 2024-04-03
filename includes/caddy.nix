{
  config,
  pkgs,
  ...
}: {
  networking.firewall.allowedTCPPorts = [443];

  systemd.services.caddy_docker-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "caddy_docker-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/tmp/caddy_docker";
    };
    script = ''
      /run/wrappers/bin/su - drew -s /bin/sh -c 'cd /tmp/; git clone https://github.com/yeltnar/caddy_docker';

      cp /home/drew/playin/nixos_files/includes/caddy/Caddyfile /tmp/caddy_docker/caddy/
      mkdir /tmp/caddy_docker/caddy/data
      mkdir /tmp/caddy_docker/caddy/config
      chown -R drew:users /tmp/caddy_docker/caddy/;
      chmod 775 /tmp/caddy_docker/caddy/*;

      # /run/wrappers/bin/su - drew -s /bin/sh -c 'cd /tmp/caddy_docker; echo "VAULTWARDEN_PATH=\"https://vaultwarden.nixos.lan\"" > .env';
      # mkdir /tmp/caddy_docker/vw-data;
      # chown drew:100 /tmp/caddy_docker/vw-data;
      # chmod 777 /tmp/caddy_docker/vw-data;
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "caddy_docker";
      WorkingDirectory = "/tmp";
      ExecStartPost = "systemctl start caddy_docker_start.service";
    };
  };

  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';
  systemd.services.caddy_docker_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];

    script = ''
      # sleep 120; # sleep so it maybe has the files
      PATH="$PATH:/run/wrappers/bin/";
      ${pkgs.podman-compose}/bin/podman-compose up 2>&1 | tee /tmp/caddy_docker/podman-compose.log
    '';

    wantedBy = ["multi-user.target"];
    # If you use podman
    requires = ["podman.service" "podman.socket"];
    unitConfig = {
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "/tmp/caddy_docker";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      # User = "drew";
      # Type = "forking";
      WorkingDirectory = "/tmp/caddy_docker";
      Restart = "always";
    };
  };
}
