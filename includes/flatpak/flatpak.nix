{
  config,
  pkgs,
  lib,
  ...
}: let
  desktop_environment = config.services.desktop_environment.selection;
in {
  config = lib.mkIf ( "none" != desktop_environment ) {
    services.flatpak.enable = true; 

    environment.systemPackages = with pkgs; [
      gnome-software
    ];
  };
}

# flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
