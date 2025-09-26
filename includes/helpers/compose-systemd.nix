{
  config,
  lib,
  pkgs,
  ...
}:
let 
  user="drew";
  get_run_env_file = name: "/home/${user}/.config/${name}/changeme.env";
  get_backup_env_file = name: "/home/${user}/.config/${name}/backup.env";

  # this returns a list which needs to all be merged together
  generateStartService = name: value: shared_vars:
  lib.mkIf ( !(value ? enable_start_service) || value.enable_start_service == false ) {
    path = with pkgs; [
      podman
      podman-compose
    ];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    requires = ["podman.service" "podman.socket"];
    after = ["nm-online.service"];
    # if the test_string var exsists, use the 'watch the logs' script
    script = if ( value.test_string != "" ) then 
    ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose down
      # ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_${name}_podman.pid --gpus=all" up --no-recreate -d
      ${pkgs.podman-compose}/bin/podman-compose up  -d

      # str="Listening on";
      str="${value.test_string}";

      testit(){
        podman-compose logs | grep "$str" >& /dev/null
        echo $?
      }

      while [ 1 -eq `testit` ] ;
      do 
        echo loop again
        sleep 1
      done

      systemd-notify --ready --status="container up"

    '' else 
    ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose down
      # ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/${name}.podman.pid" up --no-recreate -d
      # ${pkgs.podman-compose}/bin/podman-compose up -d
      ${pkgs.podman-compose}/bin/podman-compose --env-file ${shared_vars.run_env_file} --verbose up --build -d |& tee log.txt
    '';
    unitConfig = {
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "${shared_vars.code_dir}";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "${shared_vars.code_dir}";
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/${name}.podman.pid"; # TODO change pid location 
      ExecStop = pkgs.writeShellScript "stop-${name}" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down
      '';
    };
  };
  generateCloneService = name: value: shared_vars: 
  lib.mkIf ( !(value ? enable_clone_service) || value.enable_clone_service == false ) {
    path = with pkgs; [
      git
    ];
    description = "${name}-git-repo";
    # requires = ["network-online.target"];
    # after = ["default.target" "network-online.target"];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    after = ["nm-online.service"];
    unitConfig = {
      ConditionPathExists = "!${shared_vars.code_dir}";
    };

    script = let 
      clone_script = "mkdir -p ${shared_vars.code_parent_dir}; cd ${shared_vars.code_parent_dir}/; git clone ${shared_vars.git_server_uri}/${shared_vars.git_user}/${name}";
    in
      if ( value.super_user_clone == true ) then
        "${pkgs.util-linux}/bin/runuser -u ${user} -- ${pkgs.bash}/bin/bash -c '${clone_script}'"
      else 
        clone_script
    ;

    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "${name}";
      WorkingDirectory = "${shared_vars.code_parent_dir}";
    };
    onSuccess = [
      "${name}_restore.service"
    ];
  };
  # this needs to be systemd.user.timer.service
  generateBackupTimerService = name: value:
  lib.mkIf ( !(value ? enable_backup_timer_service) || value.enable_backup_timer_service == false ) {
    wantedBy = [
      "timers.target"
    ];
    timerConfig = {
      # run service based on how long it last ran 
      OnUnitInactiveSec = "6h";
      # start service when timer starts
      OnActiveSec = "0s";
      # Unit = "backup.${name}.service";
      Unit = "${name}_backup.service";
    };
  };
  generateBackupService = name: value : shared_vars:
  lib.mkIf ( !(value ? enable_backup_service) || value.enable_backup_service == false ) {
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/${user}";
      }
      // config.networking.proxy.envVars;

    path = with pkgs; [
      borgbackup
    ];

    script = shared_vars.backup_script;
    unitConfig = {
      ConditionPathExists = "/home/${user}/playin/${name}";
    };
    serviceConfig = {
      WorkingDirectory = "/home/${user}/playin/${name}";
      Type = "oneshot";
      # User = "${user}";
    };
  };

  generateRestoreService = name: value: shared_vars:
  # TODO validate restore works for root and non-root
  lib.mkIf ( !(value ? enable_restore_service) || value.enable_restore_service == false ) {
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/${user}";
      }
      // config.networking.proxy.envVars;

    path = with pkgs; [
      borgbackup
    ];
    script = shared_vars.restore_script;
    serviceConfig = {
      WorkingDirectory = "/home/${user}/playin/${name}";
      Type = "oneshot";
      # User = "${user}";

      # TODO this user shiz is wack
      # if super user, use ExecStartPost hook to start the 'start' service
      ExecStartPost = lib.mkIf (value.super_user_restore) ( pkgs.writeShellScript "poststart" "chown -R 100910:100910 config; systemctl --user -M ${user}@ ${name}_start.service" );
    };
    # unitConfig = {
    #   ConditionPathExists = "/home/${user}/playin/${unit_id}";
    # };
    onSuccess = 
      # if not super user, use on success hook to start the 'start' service
      lib.mkIf (!value.super_user_restore) [ "${name}_start.service" ]
    ;
  };

  # generateTimers = name: value: true;
  generateTimers = name: value: [
    {
      name="${name}_backup";
      value=generateBackupTimerService name value;
    }
  ];

  generateSops = name: value: 
  lib.filter ( value: null != value ) 
  [
    ( if ( value.use_run_env==true ) then 
      {
        name="${name}.env";
        value= {
          owner = "${user}";
          path = get_run_env_file name;
          sopsFile = ../${name}/secrets.yaml;
        };
      }
    else null )
    ( if ( value.backup_restore==true ) then 
    { name="${name}_backup.env";
      value={
        owner = "${user}";
        path = get_backup_env_file name;
        sopsFile = ../${name}/secrets.yaml;
      };
    }
    else null )
  ];

  composeSystemdOption.options = {
    super_user_clone = lib.mkOption { type=lib.types.bool; default=false; };
    super_user_restore = lib.mkOption { type=lib.types.bool; default=false; };
    super_user_start = lib.mkOption { type=lib.types.bool; default=false; };
    super_user_backup_timer = lib.mkOption { type=lib.types.bool; default=false; };
    super_user_backup = lib.mkOption { type=lib.types.bool; default=false; };
    allowedUDPPorts = lib.mkOption { type=lib.types.listOf lib.types.int; default=[]; };
    allowedTCPPorts = lib.mkOption { type=lib.types.listOf lib.types.int; default=[]; };
    files_to_backup = lib.mkOption { type=lib.types.string; default=""; };
    linger = lib.mkOption { type=lib.types.bool; default=false; };
    test_string = lib.mkOption { type=lib.types.string; default=""; };
    use_run_env = lib.mkOption { type=lib.types.bool; default=true; };
    backup_restore = lib.mkOption { type=lib.types.bool; default=true; };
  };

in {

  # use like
  # custom.compose.user.testme2 = {};
  # custom.compose.system.testme2 = {};
  # need example of service which needs to monitor output

  options.custom.compose = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule composeSystemdOption);
    default = null;
  };

  # TODO this should be an option that is selected... also need to change within the service spec
  imports = [ ../nm-online.service.nix ];

  # config.custom.compose.user

  # builtins.listToAttrs ( ( lib.flatten ( lib.mapAttrsToList ( generateSops ) config.custom.compose.user ) ) )
  
  config.systemd = lib.foldl' lib.recursiveUpdate {} ( lib.mapAttrsToList ( name: value: let 

    shared_vars = {
      code_parent_dir="/home/${user}/playin";
      code_dir="${shared_vars.code_parent_dir}/${name}";  
      run_env_file = get_run_env_file name;
      backup_env_file = get_backup_env_file name;

      backup_WORKDIR="/home/drew/playin/${name}";
      backup_FILES_TO_BACKUP=value.files_to_backup;
      backup_BORG_REPO="/mnt/minio/backups/${name}_backup";
      backup_ENCRYPTION="repokey";

      # for backup this is needed (provided from sops)
      # BORG_PASSPHRASE
      
      # during runtime, this is needed (provided from sops)
      # s3_access_key_id
      # s3_secret_access_key
      # s3_endpoint

      backup_script = ''
        source ${shared_vars.backup_env_file}

        WORKDIR="${shared_vars.backup_WORKDIR}"
        export FILES_TO_BACKUP="${shared_vars.backup_FILES_TO_BACKUP}";
        export BORG_REPO="${shared_vars.backup_BORG_REPO}"
        export ENCRYPTION="${shared_vars.backup_ENCRYPTION}"

        if [ -z "$WORKDIR" ]; then
          echo "WORKDIR is undefined... exiting";
          exit;
        fi
        if [ -n "$SRC_DIR" ]; then
          echo "\$SRC_DIR is replaced with \$FILES_TO_BACKUP... exiting";
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
        pwd

        info_exit_code=$(borg info $BORG_REPO >& /dev/null; echo $?)

        if [ $info_exit_code -gt 0 ]; then
          echo "repo does not exsist; creating now";
          borg init $BORG_REPO --encryption=$ENCRYPTION
        fi

        echo "FILES_TO_BACKUP is $FILES_TO_BACKUP";

        if [ -z "$FILES_TO_BACKUP" ]; then
          echo "\$FILES_TO_BACKUP is empty... backing up everything";
        else
          echo "backing up $FILES_TO_BACKUP";
        fi

        # if FILES_TO_BACKUP is empty, it will backup everything 
        # we make a little function with a subshell so we can always get a good exit code
        backup_log_file="/tmp/$$"
        create_code=$(borg create --stats --verbose --show-rc --progress --compression lz4 ::{user}-{now} $FILES_TO_BACKUP >$backup_log_file 2>&1; echo $?;);
        echo $create_code
        cat $backup_log_file;
        rm $backup_log_file;
        # echo create_code $create_code
        if [ $create_code -eq 1 ]; then
          echo "Borg has a warning";
          # systemd-notify --ready --status="warning with borg backup"
        elif [ $create_code -gt 1 ]; then
          echo "Borg backup had errors."
          exit $create_code;
        fi

        borg prune -v --list --keep-within=1d --keep-daily=7 --keep-weekly="5" --keep-monthly="12" --keep-yearly="2"
      '';
      restore_script = ''
        export RESTORE_DIR="/home/drew/playin/${name}"
        source ${shared_vars.backup_env_file}

        WORKDIR="${shared_vars.backup_WORKDIR}"
        export FILES_TO_BACKUP="${shared_vars.backup_FILES_TO_BACKUP}";
        export BORG_REPO="${shared_vars.backup_BORG_REPO}"
        export ENCRYPTION="${shared_vars.backup_ENCRYPTION}"

        if [ -z "$RESTORE_DIR" ]; then
          echo "RESTORE_DIR is undefined... exiting";
          exit;
        fi

        if [ -z "$WORKDIR" ]; then
          echo "WORKDIR is undefined... exiting";
          exit;
        fi
        if [ -n "$SRC_DIR" ]; then
          echo "\$SRC_DIR is replaced with \$FILES_TO_BACKUP... exiting";
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
          echo "repo does not exsist; exiting";
          exit 1;
        fi

        archive_name=$(borg list --sort-by timestamp --last 1 --format "{archive}")
        echo $archive_name

        # borg extract user@host:path/to/repo_directory::Monday path/to/target_directory --exclude '*.ext'
        echo "restoring"
        borg list "$BORG_REPO::$archive_name"

        cd $RESTORE_DIR

        borg extract "$BORG_REPO::$archive_name"
      '';
      git_user = "yeltnar";
      git_server_uri = "https://github.com";
    };

    # TODO allow for these to be set from module

    clone_name = "${name}_clone";
    restore_name = "${name}_restore";
    start_name = "${name}_start";
    backup_timer_name = "${name}_backup";
    backup_name = "${name}_backup";

    clone_service = generateCloneService name value shared_vars;
    restore_service = generateRestoreService name value shared_vars;
    start_service = generateStartService name value shared_vars;
    backup_timer_service = generateBackupTimerService name value;
    backup_service = generateBackupService name value shared_vars;

  in {

    user.services."${clone_name}" = lib.mkIf (!value.super_user_clone) clone_service;
    user.services."${restore_name}" = lib.mkIf (!value.super_user_restore) restore_service;
    user.services."${start_name}" = lib.mkIf (!value.super_user_start) start_service;
    user.services."${backup_name}" = lib.mkIf (!value.super_user_backup) backup_service;

    user.timers."${backup_timer_name}" = lib.mkIf (!value.super_user_backup_timer) backup_timer_service;

    services."${clone_name}" = lib.mkIf (value.super_user_clone) clone_service;
    services."${restore_name}" = lib.mkIf (value.super_user_restore) restore_service;
    services."${start_name}" = lib.mkIf (value.super_user_start) start_service;
    services."${backup_name}" = lib.mkIf (value.super_user_backup) backup_service;

    timers."${backup_timer_name}" = lib.mkIf (value.super_user_backup_timer) backup_timer_service;

  } ) config.custom.compose );

  config.sops.secrets = lib.mkIf ( config.custom.compose != null && config.custom.compose != {} ) 
  (
    builtins.listToAttrs ( ( lib.flatten ( lib.mapAttrsToList ( generateSops ) config.custom.compose ) ) )
  );

  # TODO invert logic so true is default?
  # enable lingering so service starts before user logs in
  config.users.users."${user}" = lib.foldl' lib.recursiveUpdate {} ( lib.mapAttrsToList ( name: value:
    if (  value ? linger && value.linger == true ) then
      { linger = true; }
    else {}
  ) config.custom.compose );

  # allowed ports (tcp and upd)
  # TODO I know I want to open on a single interface (ie nebula) sometimes but thats a whole other thing
  # networking.firewall.interfaces.<name>.allowedTCPPorts

  config.networking.firewall.allowedTCPPorts = 
  lib.optionals ( config.custom.compose != null && config.custom.compose != {} ) 
  (
    lib.flatten (
      lib.mapAttrsToList (
        name: value: 
          if value ? allowedTCPPorts then 
            value.allowedTCPPorts 
          else []
      ) config.custom.compose 
    )
  );

  config.networking.firewall.allowedUDPPorts = 
  lib.optionals ( config.custom.compose != null && config.custom.compose != {} ) 
  (
    lib.flatten (
      lib.mapAttrsToList (
        name: value: 
          if value ? allowedUDPPorts then 
            value.allowedUDPPorts 
          else []
      ) config.custom.compose 
    )
  );

  # TODO script to set up sops?

}

