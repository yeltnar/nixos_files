# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
args@{
  config,
  pkgs,
  ...
}: let 

  config_img_testing = ( import /home/drew/playin/nixos_files/includes/config_img/config_img.nix ( args // 
        { 
          repo_uri = "git@github.com:yeltnar/squashfs_git";  
          rev = "2b7bbadd18c10de05946781f7dd5f312dd14f70c";
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
    /home/drew/playin/nixos_files/includes/tlp.nix
    /home/drew/playin/nixos_files/includes/gaming.nix

    /home/drew/playin/nixos_files/includes/drewdate/drewdate.nix


    # toggle to mount encrypted mount 
    # config_img_testing 
    
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "drew-lin-lap"; # Define your hostname.

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
    xkb.layout = "us";
    xkb.variant = "";
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  ### some power mgmt stuff ### 
  # this seems to work 
  services.upower.ignoreLid = true;
  # these did not seem to work 
  services.logind.lidSwitch = "ignore";
  services.logind.lidSwitchExternalPower = "ignore";
  services.logind.lidSwitchDocked = "ignore";
  services.logind.powerKey = "lock";

  environment.systemPackages = with pkgs; [
    gparted

    keybase
    keybase-gui
    slack
    element-desktop

    mullvad-vpn
    gimp-with-plugins
    endeavour # gnome tasks app 

    betaflight-configurator

    obs-studio
  ];

  # remember to create sub volumes and mount points... some need to be created on the mounted volume
  fileSystems."/media/btrfs_top" = {
    device = "/dev/disk/by-uuid/47c6f308-2398-46e3-98a2-ba5b993500f4";
    fsType = "btrfs";
    options = [
      "nofail"
    ];
  };

  fileSystems."/" = {
    options = [
      "compress=zstd"
    ];
  };

  fileSystems."/nix" = {
    options = [
      "compress=zstd"
      "noatime"
    ];
  };

  fileSystems."/home" = {
    options = [
      "compress=zstd"
    ];
  };

  fileSystems."/media/ubuntu" = {
    device = "/media/ubuntu-small.img";
    fsType = "ext4";
    options = [
      "nofail"
    ];
  };

  swapDevices = [ { device = "/swap/swapfile"; } ];
}
