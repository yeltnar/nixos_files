# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
args@{
  config,
  pkgs,
  leUser,
  ...
}: 
let
  unstable = import
    (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable";
      sha256 = "0fxl020s1fmxygvi5bj8w30jq1bwynrn2xclwm5ahynw0nv9v6pv";
    })
    # reuse the current configuration
    { config = config.nixpkgs.config; };
in {
  imports = [
    ( import ./includes/sops/sops_make_age_key.nix (args // { leUser = leUser; }))

    ./includes/time-until.nix

    ./includes/make_id_rsa.nix
    # ./includes/fetch_test.nix

    ### containers ###
    # ./includes/vaultwarden.nix
    # ./includes/caddy.nix
    # ./includes/wedding_site.nix
  ];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  # MOVED TO FILE FOR MACHINES

  # !!!!!!
  # HOSTNAME MOVED TO FILE FOR MACHINES
  # !!!!!!
  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Chicago";
  # auto timezone
  # services.automatic-timezoned.enable = true; 
  # services.timesyncd.enable = false;

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

  system.activationScripts.binbash = {
    deps = ["binsh"];
    text = ''
      if [ ! -e "/bin/bash" ]; then
      	ln -s /bin/sh /bin/bash
      fi
    '';
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${leUser}" = {
    isNormalUser = true;
    description = leUser;
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [

      yq-go
      openssl
    ];

    # this has been replaced with ssh certificates 
    openssh.authorizedKeys.keys = [
    ];
  };

  environment.etc = {
    "ssh/user_ca.pub".text = ''
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4kX6s7x81tN3woXjXJHGvIQALqKS7RN6sj7N3G+euC90xztjlGyQ1rsKcAKbq94Nf4l9ZN4dO5TsTW30SzabNWzo+jEsyUWYbTK2P0NhakrY5VIGyLx7SA5BQwJvTIlor9mbtL2rwdAcuTnPz8ikaRg+OvNt9B6Qh3OM+TxMVg5sVIDFkBUx9G8G6jl9Os9kgj3FSeAHcawoWMV/PLULc+Jq8X27+Ze6QcGtxSGIlfoqGiDzLnB6Yuuo8+KuUrI+1TRkaF6zZnIuGEausctjDaODBsTdGo5nWNbo+9q5ZHHiJ52EP3YFiIj2jnVOpxz4FKwaisOC8MuV0ewodN9Mz8IZeN2Kqu0r81CgKDa0LluVGHAXfVZr8fIUSHdFfyNVzXP+IffUMs1/AKu670GpRildNiyjSM6DIouZm4ojgX/IKZTBygYLrYxXgSNC4AsG7P1ZCTfKvy2mw8/VHZt1ddpaJcTiqtx5Ck91tcRDO0ATIGSBN2xhM13N9Iyu2TiIfip5ZLAgmV5BOBgONb2FzE/KsXAxD5TcRhGr8OHXI/rIJQtMCbXy7Kg3D/b5ngq1IRo5I85zN/Y8dRqPBKj0fguxJlC+pOrwRdIyUthbUvUhBvUXwrdCCvWj9Bh5ub2rdu62/unC1Wbw2yPuFlBjqtO8kjxsV5Ta8McUjA40BIQ== user_ca
    '';
  };

  services.openssh.extraConfig =
    ''
    TrustedUserCAKeys /etc/ssh/user_ca.pub
    '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    ( import ./includes/open.nix { inherit pkgs; } )
    ( import ./includes/chrome-nix-tmp.nix { inherit pkgs; } )
    
    home-manager
    dconf2nix

    distrobox
    
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    curl
    # unstable.neovim # this is installed from the option below 
    tmux
    git
    unzip
    alejandra
    fzf
    jq
    file
    ffmpeg_6-full
    squashfsTools
    htop
    btop
    gnupg
    cryptsetup
    tree
    clang # needed to compile c # used by nvim 
    ripgrep # search files in dir # used by telescope nvim plugin
    podman-compose
    # docker-compose
    rclone

    # see about moving to nvim section 
    lua-language-server
    nixd

    tree
    duf
    tldr

    bcache-tools
    bcachefs-tools

    sops
    age # for sops encryption 
  ];

  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-tour
      xterm
    ])
    ++ (with pkgs; [
      epiphany
      totem
      geary
      seahorse
      gnome-music
    ]);

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  programs.neovim = {
    enable = true;
    # package = unstable.neovim-unwrapped;
    package = pkgs.neovim-unwrapped;
    defaultEditor = true;
    vimAlias = true; 
    viAlias = true; 
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
    settings.PermitRootLogin = "no";
  };

  virtualisation = {
    # docker = {
    #   enable = false;
    # };
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;

      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
    };
  };

  systemd.services.podman-restart.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # moved to individual file 
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  # system.stateVersion = "23.11"; # Did you read the comment?

  system.activationScripts.build_time = {
    text = ''
      date > /tmp/last_nixos_build_date;
    '';
  };
}
