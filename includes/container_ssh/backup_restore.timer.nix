{
  config,
  pkgs,
  ...
}: let
  unit_id="container_ssh";
  scripts = ( import ../helpers/backup_restore_scripts.nix ) { inherit unit_id; };
  backup_script = scripts.backup_script;
  restore_script = scripts.restore_script; 
  backup_env_file = scripts.backup_env_file;
in {

  sops.secrets."${unit_id}_backup.env" = {
    owner = "drew";
    path = backup_env_file;
    sopsFile = ./secrets.yaml;
  };
  
  systemd.timers."backup.${unit_id}" = {
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


  systemd.services."backup.${unit_id}" = {
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

  # this should not have a trigger so it only fires after the source code is downloaded 
  systemd.services."restore.${unit_id}" = {
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
    script = restore_script;
    serviceConfig = {
      WorkingDirectory = "/home/drew/playin/${unit_id}";
      Type = "oneshot";
      # User = "drew";
      ExecStartPost = pkgs.writeShellScript "poststart" "systemctl --user -M drew@ start ${unit_id}_start.service";
    };
    # unitConfig = {
    #   ConditionPathExists = "/home/drew/playin/${unit_id}";
    # };
  };
}
