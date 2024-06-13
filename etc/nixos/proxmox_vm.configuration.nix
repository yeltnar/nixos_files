# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
args@{
  config,
  pkgs,
  ...
}: let 
  # example of defining function, with optional param with fallback value 
  getName = { name ? "nixos" }: name;
in {
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    /home/drew/playin/nixos_files/generic_configuration.nix

    /home/drew/playin/nixos_files/includes/nebula.nix

    /home/drew/playin/nixos_files/includes/ntfy_report_ip_timer.nix

    ( import /home/drew/playin/nixos_files/includes/config_img/config_img.nix ( args // { repo_uri = "/tmp/t/.git"; rev = "ada00053669315682a3b1078e7d077205350cd29"; name = "date_btrfs"; } ) )
    # ( import /home/drew/playin/nixos_files/includes/config_img/config_img.nix ( args // { repo_uri = "https://github.com/yeltnar/tampermonkey_scripts"; name = "date_tampermonkey"; } ) )
  ];

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # disable xterm
  services.xserver.excludePackages = [pkgs.xterm];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      epiphany
      totem
      geary
      seahorse
      gnome-music
    ]);

  environment.systemPackages = with pkgs; [
    btrfs-progs
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # TODO add proxmos_vm specific stuff here
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = getName {}; # Define your hostname.
}
