{
  config,
  pkgs,
  ...
}: {
  systemd.timers."update_nebula_timer" = {
    wantedBy = ["timers.target"];
    requires = [ "setup_nebula_env.service" ];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "2m";
      Unit = "update_nebula_timer.service";
    };
  };

  systemd.services."update_nebula_timer" = {
    path = with pkgs; [
      nebula
      iputils
      curl
      bash
      gawk
      su
      openssl
      gnutar
      gzip
    ];

    unitConfig = {
      ConditionPathExists = "/var/yeltnar-nebula/compare_date.sh";
    };

    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/drew";
      }
      // config.networking.proxy.envVars;

    script = ''
      cd /var/yeltnar-nebula;
      bash -c 'export SUDO_USER="drew"; ./compare_date.sh' > compare_date.log
    '';
    serviceConfig = {
      Type = "oneshot";
      # User = "drew";
    };
  };
}
