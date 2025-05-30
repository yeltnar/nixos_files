{
  config,
  pkgs,
  lib, 
  ...
}:
let 
    desktop_environment = config.services.desktop_environment.selection;
in {

  config = lib.mkIf ( "cosmic" == desktop_environment ) {
    # Enable the Cosmic Desktop Environment.
    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };
  };
}
