# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      /home/drew/playin/nixos_files/generic_configuration.nix
      /home/drew/playin/nixos_files/includes/gaming.nix
      # /home/drew/playin/nixos_files/includes/systemd-proxy/systemd-proxy.nix

      /home/drew/playin/nixos_files/includes/nebula.nix

      /home/drew/playin/nixos_files/includes/rclone_mounts/rclone_mini.desktop.nix
      /home/drew/playin/nixos_files/includes/nbdkit/nbdkit.entry.nix

      # /home/drew/playin/nixos_files/includes/makemkv/makemkv.nix
    ] 
    ++
    lib.fileset.toList (
      # All default.nix files in ./.
      # lib.fileset.fileFilter (file: file.name == "systemd-proxy.nix") /home/drew/playin/nixos_files/includes/systemd-proxy
      # lib.fileset.fileFilter (file: file.hasExt "nix") /home/drew/playin/nixos_files/includes/systemd-proxy
      lib.fileset.fileFilter (file: file.hasExt "nix") /home/drew/playin/nixos_files/includes/granite-ollama-serverless
    )
    ;
   


  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sdc";
  boot.loader.grub.useOSProber = true;

  # services.getty.autologinUser = "drew";
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;


  # this should be in the hardware-config.nix file 
  # swapDevices = [ { device = "/swap/swapfile"; } ];

  fileSystems = {
    "/".options = [ "compress=zstd" ];
    "/home".options = [ "compress=zstd" ];
    "/home/drew/.local/share/Steam".options = [ "compress=zstd" ];
    "/home/drew/.cache".options = [ "compress=zstd" ];
    "/nix".options = [ "compress=zstd" "noatime" ];
    "/swap".options = [ "noatime" ];
  };

  networking.hostName = "drew-lin-desktop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable the OpenSSH daemon... this is done in generic 
  # services.openssh = {
    # enable = true;
    # settings.PasswordAuthentication = false;
    # settings.KbdInteractiveAuthentication = false;
    # settings.PermitRootLogin = "no";
  # };

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



  services.xserver = {

    # Enable the X11 windowing system.
    enable = true;

    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;

    # Configure keymap in X11
    xkb = {
      layout = "us";
      variant = "";
    };

  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  programs.adb.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    isNormalUser = true;
    description = "drew";
    extraGroups = [ "networkmanager" "wheel" "plugdev" "adbusers" ];
    packages = with pkgs; [
      discord
    #  thunderbird
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable; 
  services.xserver.videoDrivers = [ "nvidia" ]; 
  hardware.nvidia.open = false; # use non-free drivers
  # enable nvidia usage inside podman containers... maybe docker too
  hardware.nvidia-container-toolkit.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    libnbd 
    gparted
    btrfs-progs
    mullvad-vpn
    borgbackup
    nvtopPackages.nvidia
    nvitop

    age
    sops

    slack
    element-desktop

    gimp-with-plugins
    betaflight-configurator
    obs-studio

    audacity

    superTuxKart
  ];

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

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # this allows any user (not just user who mounted) to access fuse (rclone) files 
  environment.etc = {
    "fuse.conf".text = ''
    user_allow_other
    '';
  };

}
