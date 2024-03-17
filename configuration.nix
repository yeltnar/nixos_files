# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  imports = [
    # /home/drew/dotfiles/nixos/hardware-configuration.nix
    ./includes/time-until.nix
    ./includes/custom_bashrc.nix
    ./includes/dot_bashrc.nix
    ./includes/wedding_site.nix
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  # disable xterm
  services.xserver.excludePackages = [pkgs.xterm];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome = {
    enable = true;
  };

  environment.gnome.excludePackages = with pkgs.gnome; [
    epiphany
    totem
    geary
    seahorse
  ];

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    isNormalUser = true;
    description = "drew";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      firefox
      vlc
      vscodium
      #  thunderbird
    ];
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC9rjHOtb0r+kqUQA/AtZlTN9LNo/l8fDFjfjoHpF0pzx4i8N4S0765o1FEU2wbrGGhxO9iaibsWNv6ZnCtrRuqKHzV+laoDInbpOtB4Zj3qV3JRp6ANM1ct+YOQ1DDrMSFCUdTySxE3mztJ7OlCRBFMVDrQCNLFYY+ujTxEL2FzYGAUblvVHA+A4U9GTYildULTb/O9VMCVKSYc4InaBtKdlkIngIJr+ZbfWucqNP1G+OgY7wGe4/XTDqkEswgttyEpkcbXhQXZCbb7MzyqP3wwjCHLCfgkh1GDJ1R9Bzuu2BrGcTq30dRXgPTMrmhIGwScqmfIK23Y+Hxy827TQoxlccfT8i1tfWAG1ISkDlluiTM4vJdZOI9aKfkC83fCp/gfJeWwMsYIJkxQcT9IJN136ZVY/BbyymxEQPMro2jD7jvFVnkR+us7Mv0qDMQBFTaFSqEYqGaNXGf7y1JHGL2hKtfS0g7RGWwPmZwKFbTtYNRvNwROyDUoXqiolbtJZs="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCroPILe/Pm2C8OWv+CF7MsBI7l22sCA4TgQ+IfCvz1cPrco4rC9GY+WbPdzzTrheCgnAMZ8JES8lASCV6YBW9jqVUvnRZJ6P+ncmAVT/p2X0GOvBFBXrzeDzM0T6qZuLX5yYPqCEs1ws/myR8YMJmKa27TiT7KF0shrnYdDmX5z9vGZxBBmVP7iCt2dHw3R7ATjL1FJzHPMv60dBhCinaRXe/h2u8xvPi1meFdxmI5cQG8Z/9kK0CE6ONSNsEddQLjpBsfS3/uDA97YVRCtSNmMz3nNfZSEHo1Xrei4gHsr6/RNIxvLC8d+pqOBQEYwiIDwY3Th6HGubnOHoTW18fgHHL1tNE2dOBPkA/J+oyM4UsG3GKyr1JkVql7ZvfcY01XAm1gYD6sRJcDOump3GJmXhlY1xkD/2GFQWZaTJuWCouZ0iq7vOKcab18aTvVwSbUv0p9dVfvgsUo/Dl+bkExyhGDuxSY1GTKInydILw90X9OS2NcHbEo7GG52m9Zeu9TikBY76mYYTHEVHze+YJihecxTcEcK1TF3jFDoWGRD6XsPd/TvhORPHycqgwM7g+YBVUtWZSevCJ4i2l+qKqqpHfVoF41FQctafI2hRPQQPmDsDyAB9uC/Nm49JFExq0BVXdtI7WZ4jmvyanhkWPbENNe6pnEdED2Eq4ZSP0JdQ=="
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDBeZvZp1Yua3P+ifLv/a43uwZqY/YnXhc8AbSUplxQGlN+DWykOkSTBDME77ETkqryEwSW/enFdzQbd+SszNiozrPNnfDK3xnPLClg1uPBJctCj0qqzi9xsI0daVBBREWXU4biVCfqtYN1RherHpDnavvVZ2K2WZO5LR0MapCbQdQVNVMVbZuRvaX36Kq3WRodFAVRWPSYLGWdEuILwNJVAkgayDh3l/m48DrbByKDzxD3/yeejd0PVqK/2WIQ4rtJDiDy/vJpxD/teFp8ikA6tTP2BU0fCgkLP1sxZ1MC3zJCeJto8g4rqm7o2lyl1FzhOROJuT4SqlyQhH0T311XdW9aeP0FHSEBBiwABjM7ZEzH8HgLA2r+7f8PXoeqzn3mbxJG+ufwQgbyQttIiXxCgGIIfAlDjiiCCTCy0dj/YQs00zqHHux7QLD3dQgHQ7BjdAOBlqxRSJQ4eCr6f8QpJAlUi2qDEdofW0nBSCUSsIgiwj2DIKU/o1oWvFfrOSvoKX1KHCzGUgikcf1+zddJXR3XEO/0qVRXUVtxtHdH/7rRQwzcX5/2fXf8PJ5Jm6L62QuUkawLHt9SxmmyokedyAo6bQ5rz39an1KOWnKuoefV13qUeDzrCV0q7Prqay/uyfv5F0d2L5blFKqH+aGsc7U2FRcv4J4EdwJrWV/5XQ=="
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    neovim
    tmux
    git
    alejandra
    fzf
    lazygit
    jq
    file
    nebula
    ffmpeg
    nodejs_20
    xclip
    dig
    squashfsTools
    podman-compose
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.neovim.enable = true;
  programs.neovim.defaultEditor = true;

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

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
  system.stateVersion = "23.11"; # Did you read the comment?

  system.activationScripts.setup_bash_profile = {
    text = ''
      date > /tmp/testing_info;

      text_to_add='if [ -f ~/.bashrc ]; then . ~/.bashrc; fi'
      text_to_check='# bashrc_load_done # text showing the .bashrc loading is added to profile';

      # create if not there
      if [ ! -e /home/drew/.bash_profile ]; then
        touch /home/drew/.bash_profile;
      fi

      test_str=$(cat /home/drew/.bash_profile | grep "$text_to_check");
      # echo $text_to_check;
      # echo $test_str;

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bash_profile;
        echo "$text_to_add" >> /home/drew/.bash_profile;
      fi

      date > /tmp/testing_info_2;
    '';
  };

  system.activationScripts.code_symlink = {
    text = ''
      text_to_add='alias code="codium"';
      text_to_check='# code_alias_done';

      # create if not there
      if [ ! -e /home/drew/.bash_profile ]; then
        touch /home/drew/.bash_profile;
      fi

      test_str=$(cat /home/drew/.bash_profile | grep "$text_to_check");

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bash_profile;
        echo "$text_to_add" >> /home/drew/.bash_profile;
      fi
    '';
  };

  system.activationScripts.build_time = {
    text = ''
      date > /tmp/last_nixos_build_date;
    '';
  };
}
