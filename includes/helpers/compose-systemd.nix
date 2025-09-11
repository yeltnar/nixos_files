{
  config,
  lib,
  pkgs,
  ...
}:
# TODO can I like import each one and not have to loop over each attribute? 
let 
  user="drew";
  get_run_env_file = name: "/home/${user}/.config/${name}/changeme.env";
  get_backup_env_file = name: "/home/${user}/.config/${name}/backup.env";

  # this returns a list which needs to all be merged together
  generateServices = name: value: let
    shared_vars = {
      code_parent_dir="/home/${user}/playin";
      code_dir="${shared_vars.code_parent_dir}/${name}";  
      scripts = ( import ./backup_restore_scripts.nix ) { unit_id = name; };
      backup_script = shared_vars.scripts.backup_script;
      restore_script = shared_vars.scripts.restore_script;
      git_user = "yeltnar";
      git_server_uri = "https://github.com";
      run_env_file = get_run_env_file name;
      backup_env_file = get_backup_env_file name;
    };
  in [
    {
      name="${name}_start";
      value=generateStartService name value shared_vars;
    }
    {
      name="${name}_clone";
      value=generateCloneService name value shared_vars;
    }
    # {
    #   name="timers.${name}_backup";
    #   value=generateBackupTimerService name value shared_vars;
    # }
    # {
    #   name="timers";
    #   value={
    #     "${name}_backup" = generateBackupTimerService name value shared_vars;
    #   };
    # }
    {
      name="${name}_backup";
      value=generateBackupService name value shared_vars;
    }
    {
      name="${name}_restore";
      value=generateRestoreService name value shared_vars;
    }
  ];
  generateStartService = name: value: shared_vars:
  {
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
    script = if value ? test_string then 
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
  {
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
    script = ''
      cd ${shared_vars.code_parent_dir}/; git clone ${shared_vars.git_server_uri}/${shared_vars.git_user}/${name};
    '';
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
  generateBackupTimerService = name: value: {
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
  generateBackupService = name: value : shared_vars: {
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

  generateRestoreService = name: value: shared_vars: {
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
    };
    # unitConfig = {
    #   ConditionPathExists = "/home/${user}/playin/${unit_id}";
    # };
    onSuccess = [
      "${name}_start.service"
    ];
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
    ( if (value ? use_run_env && value.use_run_env==true) then 
      {
        name="${name}.env";
        value= {
          owner = "${user}";
          path = get_run_env_file name;
          sopsFile = ../${name}/secrets.yaml;
        };
      }
    else null )
    ( if (value ? backup_restore && value.backup_restore==true) then 
    { name="${name}_backup.env";
      value={
        owner = "${user}";
        path = get_backup_env_file name;
        sopsFile = ../${name}/secrets.yaml;
      };
    }
    else null )
  ];

in {

  # use like
  # custom.compose.user.testme2 = {};
  # custom.compose.system.testme2 = {};
  # need example of service which needs to monitor output

  options.custom.compose.user = lib.mkOption {
    default = null;
  };

  options.custom.compose.system = lib.mkOption {
    default = null;
  };

  # TODO this should be an option that is selected... also need to change within the service spec
  imports = [ ../nm-online.service.nix ];

  # TODO this needs to be an option but that seems like a bunch of 'or' statements
  # enable lingering so service starts before user logs in
  config.users.users.drew.linger = true;

  # map system key to be system services
  config.systemd.services = lib.mkIf ( config.custom.compose.system != null && config.custom.compose.system != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList ( generateServices ) config.custom.compose.system ) )
  );

  # map user key to be user services
  config.systemd.user.services = lib.mkIf ( config.custom.compose.user != null && config.custom.compose.user != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList ( generateServices ) config.custom.compose.user ) )
  );

  # map user key to be user timers
  config.systemd.user.timers = lib.mkIf ( config.custom.compose.user != null && config.custom.compose.user != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList ( generateTimers ) config.custom.compose.user ) )
  );
  config.systemd.timers = lib.mkIf ( config.custom.compose.system != null && config.custom.compose.system != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList ( generateTimers ) config.custom.compose.system ) )
  );

  # allowed ports (tcp and upd)
  # TODO I know I want to open on a single interface (ie nebula) sometimes but thats a whole other thing
  config.networking.firewall.allowedTCPPorts = 
  lib.optionals ( config.custom.compose.user != null && config.custom.compose.user != {} ) 
  (
    lib.flatten (
      lib.mapAttrsToList (
        name: value: 
          if value ? allowedTCPPorts then 
            value.allowedTCPPorts 
          else []
      ) config.custom.compose.user 
    )
  )
  ++ 
  lib.optionals ( config.custom.compose.system != null && config.custom.compose.system != {} ) 
  (
    lib.flatten (
      lib.mapAttrsToList (
        name: value: 
          if value ? allowedTCPPorts then 
            value.allowedTCPPorts 
          else []
      ) config.custom.compose.system 
    )
  );

  config.networking.firewall.allowedUDPPorts = 
  lib.optionals ( config.custom.compose.user != null && config.custom.compose.user != {} ) 
  (
    lib.flatten (
      lib.mapAttrsToList (
        name: value: 
          if value ? allowedUDPPorts then 
            value.allowedUDPPorts 
          else []
      ) config.custom.compose.user 
    )
  )
  ++ 
  lib.optionals ( config.custom.compose.system != null && config.custom.compose.system != {} ) 
  (
    lib.flatten (
      lib.mapAttrsToList (
        name: value: 
          if value ? allowedUDPPorts then 
            value.allowedUDPPorts 
          else []
      ) config.custom.compose.system 
    )
  );

  config.sops.secrets = lib.mkIf ( config.custom.compose.user != null && config.custom.compose.user != {} ) 
  (
    builtins.listToAttrs ( ( lib.flatten ( lib.mapAttrsToList ( generateSops ) config.custom.compose.user ) ) )
  );


  # TODO  need to be able to turn on/off backup and restore

}

