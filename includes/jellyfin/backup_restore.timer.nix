{
  config,
  pkgs,
  ...
}: {
  systemd.timers."backup.jellyfin" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      # TODO DELETE BOOT SEC AND REPLWCE WITH DEPEND
      OnBootSec = "5m";
      OnCalendar = "6h";
      Unit = "backup.jellyfin.service";
    };
  };


  systemd.user.services."backup.jellyfin" = {
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/drew";
      }
      // config.networking.proxy.envVars;

    path = with pkgs; [
      borgbackup
    ];

    script = ''
      ./backup.sh
    '';
    serviceConfig = {
      WorkingDirectory = "/home/drew/playin/jellyfin";
      Type = "oneshot";
      # User = "drew";
    };
  };

  systemd.user.services."restore.jellyfin" = {
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/drew";
      }
      // config.networking.proxy.envVars;

    path = with pkgs; [
      borgbackup
    ];

    script = ''
      export RESTORE_DIR="$HOME/playin/jellyfin"
      ./restore.sh
    '';
    serviceConfig = {
      WorkingDirectory = "/home/drew/playin/jellyfin";
      Type = "oneshot";
      ExecStop = "systemctl --user start jellyfin_start.service";
      # User = "drew";
    };
  };
}
