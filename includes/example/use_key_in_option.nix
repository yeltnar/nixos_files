{
  config,
  lib,
  pkgs,
  ...
}:{

 # use like `my.test.testme2 = {};`

  options.my.test = lib.mkOption {
    default = null;
  };

  config.environment.systemPackages = lib.mkIf ( config.my.test != null && config.my.test != {} ) 
  (
    lib.attrsets.mapAttrsToList (name: value: pkgs.writeShellScriptBin name "echo \"this is an example of using a key: ${name}\"" ) config.my.test 
  )
  //
  pkgs.writeShellScriptBin "fmd3" "echo fmd3";

}
