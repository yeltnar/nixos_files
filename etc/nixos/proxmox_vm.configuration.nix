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

  config_img_testing = ( import /home/drew/playin/nixos_files/includes/config_img/config_img.nix ( args // 
    { 
      repo_uri = "git@github.com:yeltnar/squashfs_git"; 
      rev = "c3121a9ffc86b82f47dd5ac3bfd0f0584319804c";
      name = "sqfs_test"; 
      mount_point = "/media/sqfs_test";
      fsType = "squashfs";
      options = [
        "nofail"
      ];
    }
  ));

in {
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    /home/drew/playin/nixos_files/generic_configuration.nix

    /home/drew/playin/nixos_files/includes/nebula.nix

    /home/drew/playin/nixos_files/includes/ntfy_report_ip_timer.nix

    /home/drew/playin/nixos_files/includes/derivation_test/derivation_test.nix
    # /home/drew/playin/nixos_files/includes/nextcloud/nextcloud.nix
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

  # Configure keymap in X11
  services.xserver = {
    xkb = {
      layout = "us";
      variant = "";
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # TODO add proxmos_vm specific stuff here
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = getName {}; # Define your hostname.
}
