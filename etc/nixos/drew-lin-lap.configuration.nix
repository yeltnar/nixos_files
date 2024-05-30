# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    /home/drew/playin/nixos_files/generic_configuration.nix

    /home/drew/playin/nixos_files/includes/nebula.nix
    /home/drew/playin/nixos_files/includes/tlp.nix
    /home/drew/playin/nixos_files/includes/gaming.nix

    /home/drew/playin/nixos_files/includes/drewdate/drewdate.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "drew-lin-lap"; # Define your hostname.

  environment.systemPackages = with pkgs; [
    keybase
    keybase-gui
    slack
    element-desktop

    mullvad-vpn
    gimp-with-plugins

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
