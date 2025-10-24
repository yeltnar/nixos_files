# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    # generate with mkpasswd 
    # hashedPassword = "";
    description = "drew";
    extraGroups = [ 
      "networkmanager"
      "wheel"
      "plugdev"
      "adbusers" 
    ];
    group = "drew";
    isNormalUser = true;
    openssh.authorizedKeys.keys = [   
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9rjHOtb0r+kqUQA/AtZlTN9LNo/l8fDFjfjoHpF0pzx4i8N4S0765o1FEU2wbrGGhxO9iaibsWNv6ZnCtrRuqKHzV+laoDInbpOtB4Zj3qV3JRp6ANM1ct+YOQ1DDrMSFCUdTySxE3mztJ7OlCRBFMVDrQCNLFYY+ujTxEL2FzYGAUblvVHA+A4U9GTYildULTb/O9VMCVKSYc4InaBtKdlkIngIJr+ZbfWucqNP1G+OgY7wGe4/XTDqkEswgttyEpkcbXhQXZCbb7MzyqP3wwjCHLCfgkh1GDJ1R9Bzuu2BrGcTq30dRXgPTMrmhIGwScqmfIK23Y+Hxy827TQoxlccfT8i1tfWAG1ISkDlluiTM4vJdZOI9aKfkC83fCp/gfJeWwMsYIJkxQcT9IJN136ZVY/BbyymxEQPMro2jD7jvFVnkR+us7Mv0qDMQBFTaFSqEYqGaNXGf7y1JHGL2hKtfS0g7RGWwPmZwKFbTtYNRvNwROyDUoXqiolbtJZs="
"ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBeZvZp1Yua3P+ifLv/a43uwZqY/YnXhc8AbSUplxQGlN+DWykOkSTBDME77ETkqryEwSW/enFdzQbd+SszNiozrPNnfDK3xnPLClg1uPBJctCj0qqzi9xsI0daVBBREWXU4biVCfqtYN1RherHpDnavvVZ2K2WZO5LR0MapCbQdQVNVMVbZuRvaX36Kq3WRodFAVRWPSYLGWdEuILwNJVAkgayDh3l/m48DrbByKDzxD3/yeejd0PVqK/2WIQ4rtJDiDy/vJpxD/teFp8ikA6tTP2BU0fCgkLP1sxZ1MC3zJCeJto8g4rqm7o2lyl1FzhOROJuT4SqlyQhH0T311XdW9aeP0FHSEBBiwABjM7ZEzH8HgLA2r+7f8PXoeqzn3mbxJG+ufwQgbyQttIiXxCgGIIfAlDjiiCCTCy0dj/YQs00zqHHux7QLD3dQgHQ7BjdAOBlqxRSJQ4eCr6f8QpJAlUi2qDEdofW0nBSCUSsIgiwj2DIKU/o1oWvFfrOSvoKX1KHCzGUgikcf1+zddJXR3XEO/0qVRXUVtxtHdH/7rRQwzcX5/2fXf8PJ5Jm6L62QuUkawLHt9SxmmyokedyAo6bQ5rz39an1KOWnKuoefV13qUeDzrCV0q7Prqay/uyfv5F0d2L5blFKqH+aGsc7U2FRcv4J4EdwJrWV/5XQ=="
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMrfvmzNiYcstU6F0YRCBog9SxLBzvgvhiZtpwsvYTnJ"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILvC5vmtaFNGktJ7EL4KYRDyMVwHkgilZG6qwf5QCozt"
"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+Nm7VWCnj5GtZNsESBCy6uy+27a2PgJNKKC9A6wmMi"
];
  };

  users.groups.drew = {};

  services.openssh.enable = true;


  environment.etc = {
    "ssh/user_ca.pub".text = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4kX6s7x81tN3woXjXJHGvIQALqKS7RN6sj7N3G+euC90xztjlGyQ1rsKcAKbq94Nf4l9ZN4dO5TsTW30SzabNWzo+jEsyUWYbTK2P0NhakrY5VIGyLx7SA5BQwJvTIlor9mbtL2rwdAcuTnPz8ikaRg+OvNt9B6Qh3OM+TxMVg5sVIDFkBUx9G8G6jl9Os9kgj3FSeAHcawoWMV/PLULc+Jq8X27+Ze6QcGtxSGIlfoqGiDzLnB6Yuuo8+KuUrI+1TRkaF6zZnIuGEausctjDaODBsTdGo5nWNbo+9q5ZHHiJ52EP3YFiIj2jnVOpxz4FKwaisOC8MuV0ewodN9Mz8IZeN2Kqu0r81CgKDa0LluVGHAXfVZr8fIUSHdFfyNVzXP+IffUMs1/AKu670GpRildNiyjSM6DIouZm4ojgX/IKZTBygYLrYxXgSNC4AsG7P1ZCTfKvy2mw8/VHZt1ddpaJcTiqtx5Ck91tcRDO0ATIGSBN2xhM13N9Iyu2TiIfip5ZLAgmV5BOBgONb2FzE/KsXAxD5TcRhGr8OHXI/rIJQtMCbXy7Kg3D/b5ngq1IRo5I85zN/Y8dRqPBKj0fguxJlC+pOrwRdIyUthbUvUhBvUXwrdCCvWj9Bh5ub2rdu62/unC1Wbw2yPuFlBjqtO8kjxsV5Ta8McUjA40BIQ== user_ca
    '';
  };

  services.openssh.extraConfig = ''
    TrustedUserCAKeys /etc/ssh/user_ca.pub
  '';



 boot.supportedFilesystems = [ "btrfs" ];

 boot.loader.grub.device = "/dev/sda";

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # services.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     tree
  #   ];
  # };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

