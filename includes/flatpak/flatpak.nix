{
  config,
  pkgs,
  ...
}: {
  services.flatpak.enable = true; 

  environment.systemPackages = with pkgs; [
    gnome-software
  ];
}

# flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
