{
  config,
  pkgs,
  lib, 
  ...
}: 
let
    desktop_environment = lib.mkDefault "gnome";
in {

  environment.systemPackages = with pkgs; [

    ## check the Gnome Extensions app for settings 
    # better workspace management 
    gnomeExtensions.space-bar
    # 'spotlight' with Super+W
    gnomeExtensions.switcher
    # settings with Shift+Super+T
    # grid overlay with Super+T
    gnomeExtensions.tactile
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-tour
      xterm
      epiphany
      totem
      geary
      seahorse
      gnome-music
      decibels
    ]);
}
