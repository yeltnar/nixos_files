{
  config,
  pkgs,
  ...
}: {
  systemd.user.timers."backup.jellyfin" = {
    wantedBy = ["timers.target"];
    unitConfig = {
      ConditionPathExists = "/home/drew/playin/jellyfin/config";
    };
    timerConfig = {
      # TODO DELETE BOOT SEC AND REPLWCE WITH DEPEND
      OnUnitInactiveSec = "6h";
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
    unitConfig = {
      ConditionPathExists = "/home/drew/playin/jellyfin/config";
    };
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
      # User = "drew";
    };
    onSuccess = [
      "jellyfin_start.service"
    ];
  };
}
