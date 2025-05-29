{
  config,
  pkgs,
  lib, 
  ...
}: 
let
    desktop_environment = lib.mkDefault "gnome";
in {
  # Enable the Cosmic Desktop Environment.
  services.displayManager.cosmic-greeter.enable = true;
  services.desktopManager.cosmic.enable = true;
}
