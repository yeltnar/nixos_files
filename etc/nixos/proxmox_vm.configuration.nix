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

  environment.etc.crypttab.text = ''
    enc_sqfs /home/drew/tmp_git_server/first_disk/enc.img /root/mykeyfile.key 
  '';

  fileSystems."/home/drew/tmp_git_server/first_disk/enc_mnt" =
    { 
      device = "/dev/mapper/enc_sqfs";
      fsType = "squashfs";
      options = [ "nofail" ];
    };


  imports = [
    # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    /home/drew/playin/nixos_files/generic_configuration.nix

    /home/drew/playin/nixos_files/includes/nebula.nix

    /home/drew/playin/nixos_files/includes/ntfy_report_ip_timer.nix

    ( import /home/drew/playin/nixos_files/includes/config_img/config_img.nix ( args // 
      { 
        repo_uri = "/home/drew/tmp_git_server/first_disk/.git"; 
        rev = "61eb65687463d31390a0518e5392be16517663c3"; 
        name = "date_btrfs"; 
        mount_point = "/media/btrfs_test";
        fsType = "btrfs";
	options = [
          "nofail"
          "compress=zstd"
          "subvol=root"
        ];
      }
    ))
    ( import /home/drew/playin/nixos_files/includes/config_img/config_img.nix ( args // 
      { 
        repo_uri = "git@github.com:yeltnar/squashfs_git"; 
        rev = "18b70ecb7778f9e0b1980ddb5c57c1df5d795666"; 
        name = "sqfs_test"; 
        mount_point = "/media/sqfs_test";
        fsType = "squashfs";
	options = [
          "nofail"
        ];
      }
    ))
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
    cryptsetup
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
