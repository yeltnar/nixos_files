# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

nix.settings.trusted-users = ["drew"];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    isNormalUser = true;
    description = "drew";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  # neovim
  # curl
  # git
  # lazygit
  # tmux
  # nebula
  ];

  environment.etc = {
    "ssh/user_ca.pub".text = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4kX6s7x81tN3woXjXJHGvIQALqKS7RN6sj7N3G+euC90xztjlGyQ1rsKcAKbq94Nf4l9ZN4dO5TsTW30SzabNWzo+jEsyUWYbTK2P0NhakrY5VIGyLx7SA5BQwJvTIlor9mbtL2rwdAcuTnPz8ikaRg+OvNt9B6Qh3OM+TxMVg5sVIDFkBUx9G8G6jl9Os9kgj3FSeAHcawoWMV/PLULc+Jq8X27+Ze6QcGtxSGIlfoqGiDzLnB6Yuuo8+KuUrI+1TRkaF6zZnIuGEausctjDaODBsTdGo5nWNbo+9q5ZHHiJ52EP3YFiIj2jnVOpxz4FKwaisOC8MuV0ewodN9Mz8IZeN2Kqu0r81CgKDa0LluVGHAXfVZr8fIUSHdFfyNVzXP+IffUMs1/AKu670GpRildNiyjSM6DIouZm4ojgX/IKZTBygYLrYxXgSNC4AsG7P1ZCTfKvy2mw8/VHZt1ddpaJcTiqtx5Ck91tcRDO0ATIGSBN2xhM13N9Iyu2TiIfip5ZLAgmV5BOBgONb2FzE/KsXAxD5TcRhGr8OHXI/rIJQtMCbXy7Kg3D/b5ngq1IRo5I85zN/Y8dRqPBKj0fguxJlC+pOrwRdIyUthbUvUhBvUXwrdCCvWj9Bh5ub2rdu62/unC1Wbw2yPuFlBjqtO8kjxsV5Ta8McUjA40BIQ== user_ca
    '';
  };

  services.openssh.extraConfig = ''
  # TrustedUserCAKeys /etc/ssh/user_ca.pub
  '';

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
