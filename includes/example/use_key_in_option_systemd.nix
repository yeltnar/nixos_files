{
  config,
  lib,
  pkgs,
  ...
}:
let 
  # this returns a list which needs to all be merged together
  generateServices = name: value: [
    {
      name="${name}_start";
      value=generateStartService name value;
    }
    {
      name="${name}_clone";
      value=generateCloneService name value;
    }
    {
      name="${name}_backup_timer";
      value=generateBackupTimerService name value;
    }
    {
      name="${name}_backup";
      value=generateBackupService name value;
    }
  ];
  generateStartService = name: value: { script = "date > /tmp/${name}_start"; };
  generateCloneService = name: value: { script = "date > /tmp/${name}_clone"; };
  generateBackupTimerService = name: value: { script = "date > /tmp/${name}_backup_timer"; };
  generateBackupService = name: value : { script = "date > /tmp/${name}_backup"; };
in {

  # use like
  # my.test.user.testme2 = {};
  # my.test.system.testme2 = {};

  options.my.test.user = lib.mkOption {
    default = null;
  };

  options.my.test.system = lib.mkOption {
    default = null;
  };

  # map system key to be system services
  config.systemd.services = lib.mkIf ( config.my.test.system != null && config.my.test.system != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList ( generateServices ) config.my.test.system ) )
  );

  # map user key to be user services
  config.systemd.user.services = lib.mkIf ( config.my.test.user != null && config.my.test.user != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.listToAttrs ( lib.flatten ( lib.mapAttrsToList ( generateServices ) config.my.test.user ) )
  );

}

