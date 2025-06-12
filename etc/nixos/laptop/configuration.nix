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
    ../../../includes/desktop/desktop.nix

    ( import ../../../includes/nebula/nebula.nix (args // {
      user = leUser; 
      group = "100"; 
    }))
    ../../../includes/tlp.nix
    ../../../includes/gaming.nix

    # ../../../includes/drewdate/drewdate.nix

    ../../../includes/rclone_mounts/rclone_mini.laptop.nix
    ../../../includes/rclone_mounts/mini-minio.nix
    # ../../../includes/libvirt/libvirt.nix

    # ../../../includes/makemkv/makemkv.entry.nix
  ];

  # TODO make them all under yeltnar?
  services.desktop_environment.selection = "cosmic";

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

  # TODO move this block 
  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  # sops.secrets."mnt-minio.env" = {};
  sops.secrets.yeltnar_nebula_id_rsa = {
  };
  sops.secrets."digital_ocean_sops_key" = {
    owner = leUser;
    sopsFile = ../digital-ocean/secrets/secrets.yaml;
    path = "/home/drew/playin/nixos_files/etc/nixos/digital-ocean/keys.txt";
  };
  sops.secrets."nixos2_sops_key" = {
    owner = leUser;
    sopsFile = ../nixos2/secrets/secrets.yaml;
    path = "/home/drew/playin/nixos_files/etc/nixos/nixos2/keys.txt";
  };

  # Enable the GNOME Desktop Environment.
  # disable xterm
  # prevent suspend before the user logs in 
  services.xserver.displayManager.gdm.autoSuspend = false;

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

    qemu

    gparted

    keybase
    keybase-gui
    slack
    element-desktop

    mullvad-vpn
    gimp3-with-plugins
    endeavour # gnome tasks app 

    betaflight-configurator

    obs-studio
  ];

  # TLS certificates to install as system certs 
  security.pki.certificates = [
  ''
    -----BEGIN CERTIFICATE-----
    MIIBozCCAUqgAwIBAgIRAPZn1/oD/c0M9GhKndrWbmcwCgYIKoZIzj0EAwIwMDEu
    MCwGA1UEAxMlQ2FkZHkgTG9jYWwgQXV0aG9yaXR5IC0gMjAyMSBFQ0MgUm9vdDAe
    Fw0yMTEwMDMwNDIzNDdaFw0zMTA4MTIwNDIzNDdaMDAxLjAsBgNVBAMTJUNhZGR5
    IExvY2FsIEF1dGhvcml0eSAtIDIwMjEgRUNDIFJvb3QwWTATBgcqhkjOPQIBBggq
    hkjOPQMBBwNCAAR4V9bn+bmOJfWlIGkNZyy+FzHCxIZiU3Ko6f+MgY9fbZddVvZU
    +qUMqdj1jOOSHGb2oksfABkhrJAnNcqtafH9o0UwQzAOBgNVHQ8BAf8EBAMCAQYw
    EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUGxw7vsSlsHoIbX3fqTwnH8+8
    Ni0wCgYIKoZIzj0EAwIDRwAwRAIgAPmMzq8t6N9H6wUyxEjYZY870ysKNxtrBrmK
    JmH3busCICZnli09FnPU9/3mt6Kf1AhEF6X3evM+J/P1gEGOqM9u
    -----END CERTIFICATE-----''
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
