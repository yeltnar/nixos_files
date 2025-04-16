{
  config,
  pkgs,
  ...
}: {
  systemd.user.timers."backup.jellyfin" = {
    wantedBy = [
      "timers.target"
    ];
    timerConfig = {
      # run service based on how long it last ran 
      OnUnitInactiveSec = "6h";
      # start service when timer starts
      OnActiveSec = "0s";
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
