# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
args@{
  config,
  pkgs,
  ...
}: 
let
  leUser = "drew";
in 
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ( import ../../../generic_configuration.nix (args // { leUser = leUser; }))
    ../../../desktop.nix

    ( import ../../../includes/nebula/nebula.nix (args // {
      user = leUser; 
      group = "100"; 
    }))
    ../../../includes/tlp.nix
    ../../../includes/gaming.nix

    # ../../../includes/drewdate/drewdate.nix

    ../../../includes/rclone_mounts/rclone_mini.laptop.nix
    ../../../includes/libvirt/libvirt.nix

    # ../../../includes/makemkv/makemkv.entry.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
  
  # this allows any user (not just user who mounted) to access fuse (rclone) files 
  environment.etc = {
    "fuse.conf".text = ''
    user_allow_other
    '';
  };

  networking.hostName = "drew-lin-lap"; # Define your hostname.

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # TODO move this block 
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/home/${leUser}/.config/sops/age/keys.txt";
  sops.secrets.yeltnar_nebula.id_rsa = {};

  # Enable the GNOME Desktop Environment.
  # disable xterm
  services.xserver.displayManager.gdm = {
    enable = true;
    # prevent suspend before the user logs in 
    autoSuspend = false;
  };
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

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
    
    ( import ../../../includes/force_charge.nix { inherit pkgs; } )

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

  # TLS certificates to install as system certs 
  # security.pki.certificates = [];   

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
