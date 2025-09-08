{
  config,
  lib,
  pkgs,
  ...
}:
let 
  generateService = name: value: {
    script = "date > /tmp/${name}_testing";
  };
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
    builtins.mapAttrs generateService config.my.test.system 
  );

  # map user key to be user services
  config.systemd.user.services = lib.mkIf ( config.my.test.user != null && config.my.test.user != {} ) 
  (
    # this will replace the contents of the value with what is returned from the function. The key will stay the same
    builtins.mapAttrs generateService config.my.test.user 
  );

}

