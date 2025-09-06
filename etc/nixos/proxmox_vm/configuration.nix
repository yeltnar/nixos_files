# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
args@{
  # config,
  pkgs,
  ...
}: let 
  # example of defining function, with optional param with fallback value 
  getName = { name ? "nixos-testing" }: name;

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
  leUser = "drew";
in {
  # can not use absolute path for /home or /etc
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ( import ../../../generic_configuration.nix (args // { leUser = leUser; }))
    ../../../includes/desktop/desktop.nix

    ( import ../../../includes/nebula/nebula.nix (args // {
      user = leUser; 
      group = "100"; 
    }))

    ../../../includes/rclone_mounts/rclone_mini.proxmoxvm.nix

    ../../../includes/ntfy_report/ntfy_report_ip_timer.nix
    ../../../includes/mqtt_report/mqtt_report_ip_timer.nix

    ../../../includes/jellyfin/jellyfin.nix
    ../../../includes/jellyfin/backup_restore.timer.nix

    ../../../includes/uptime-kuma/uptime-kuma-server.nix
    ../../../includes/uptime-kuma/backup_restore.timer.nix

    # ../../../includes/babybuddy/babybuddy.nix
    # ../../../includes/babybuddy/backup_restore.timer.nix

    ../../../includes/derivation_test/derivation_test.nix

    # ../../../includes/nextcloud/nextcloud.nix

    # ../../../includes/vm/vm.nix
    ../../../includes/nbdkit/nbdkit.entry.nix
    ../../../includes/rclone_mounts/mini-minio.nix
  ];

  services.desktop_environment.selection = "none";

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets."mnt-minio.env" = {};

  nix.settings.trusted-users = [ "drew" ];

  environment.systemPackages = with pkgs; [
    libnbd
    # (import /home/drew/playin/nixos_files/includes/nbdkit/nbdkit.nix)
    gparted
    
    borgbackup    
    lazygit

    mosquitto
  ];

  # add proxmos_vm specific stuff here
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

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

  networking.hostName = getName {}; # Define your hostname.
}
