{
  config,
  pkgs,
  ...
}: let
  unit_id = "ntfy_server";
  backup_env_file = "/home/drew/.config/${unit_id}/backup.env";
  backup_script = ''
    source ${backup_env_file}

    if [ -z "$WORKDIR" ]; then
      echo "WORKDIR is undefined... exiting";
      exit;
    fi
    if [ -z "$SRC_DIR" ]; then
      echo "SRC_DIR is undefined... exiting";
      exit;
    fi
    if [ -z "$BORG_REPO" ]; then
      echo "BORG_REPO is undefined... exiting";
      exit;
    fi
    if [ -z "$BORG_PASSPHRASE" ]; then
      echo "BORG_PASSPHRASE is undefined... exiting";
      exit;
    fi
    if [ -z "$ENCRYPTION" ]; then
      echo "ENCRYPTION is undefined... exiting";
      exit;
    fi

    cd "$WORKDIR";

    borg info $BORG_REPO >& /dev/null
    info_exit_code=$?;

    if [ $info_exit_code -gt 0 ]; then
      echo "repo does not exsist; creating now";
      borg init $BORG_REPO --encryption=$ENCRYPTION
    fi

    borg create --stats --progress --compression lz4 ::{user}-{now}  $SRC_DIR

    borg prune -v --list --keep-within=1d --keep-daily=7 --keep-weekly="5" --keep-monthly="12" --keep-yearly="2"
  '';
in {

  sops.secrets."${unit_id}_backup.env" = {
    owner = "drew";
    path = backup_env_file;
  };
  
  systemd.user.timers."backup.${unit_id}" = {
    wantedBy = [
      "timers.target"
    ];
    timerConfig = {
      # run service based on how long it last ran 
      OnUnitInactiveSec = "6h";
      # start service when timer starts
      OnActiveSec = "0s";
      Unit = "backup.${unit_id}.service";
    };
  };


  systemd.user.services."backup.${unit_id}" = {
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

    script = backup_script;
    unitConfig = {
      ConditionPathExists = "/home/drew/playin/${unit_id}";
    };
    serviceConfig = {
      WorkingDirectory = "/home/drew/playin/${unit_id}";
      Type = "oneshot";
      # User = "drew";
    };
  };

  systemd.user.services."restore.${unit_id}" = {
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
      export RESTORE_DIR="$HOME/playin/${unit_id}"
      ./restore.sh
    '';
    serviceConfig = {
      WorkingDirectory = "/home/drew/playin/${unit_id}";
      Type = "oneshot";
      # User = "drew";
    };
    # unitConfig = {
    #   ConditionPathExists = "/home/drew/playin/${unit_id}";
    # };
    onSuccess = [
      "${unit_id}_start.service"
    ];
  };
}
