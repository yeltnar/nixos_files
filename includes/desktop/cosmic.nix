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

    services.geoclue2.enable = true;
    services.geoclue2.enableDemoAgent = false;

  # Enable the Cosmic Desktop Environment.
    services = {
      displayManager.cosmic-greeter.enable = true;
      desktopManager.cosmic.enable = true;
      desktopManager.cosmic.xwayland.enable = true;
    };
  };
}
