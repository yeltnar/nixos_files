# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

args@{ config, pkgs, ... }:

let
  leUser = "drew";
in {
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ( import ../../../includes/nebula/nebula.nix ( args // { user = leUser; SECONDARY_HOST="hot.andbrant.com"; SECONDARY_CURL_OPTIONS=""; } ) )
      ( import ../../../includes/sops/sops_make_age_key.nix (args // { leUser = leUser; }))
      ../../../includes/custom_bashrc.nix
      ../../../includes/nixos_files.nix

      ../../../includes/rclone_mounts/mini-minio.nix

      ../../../includes/caddy-server/do-nixos-caddy-server.nix
      ../../../includes/caddy-server/backup_restore.timer.nix

      ../../../includes/ntfy_server/ntfy-server.nix
      # ../../../includes/ntfy_server/backup_restore.timer.nix

      # ../../../includes/wireguard_server/backup_restore.timer.nix

      ../../../includes/container_ssh/conainer_ssh.nix
      ../../../includes/container_ssh/backup_restore.timer.nix

      ../../../includes/ntfy_report/ntfy_report_ip_timer.nix
      ../../../includes/ntfy_report/ntfy_report_ip_check.nix
      ../../../includes/ssh/ssh_cert.nix
    ];

  custom.compose.wireguard_server = {
    allowedUDPPorts = [
      51820
    ];
    files_to_backup="data allocation.txt";
    linger = true;
    use_run_env = false;
    test_string = "All tunnels are now active";
    backup_restore = false; 

    super_user_clone = true;
    super_user_start = true;

    super_user_restore = true;
    super_user_backup_timer = true;
    super_user_backup = true;
  };
  # this is my hack to get it to work... I have not been able to find the correct 'after' to get it to work 
  systemd.services.restart_wireguard = {
    script = ''
    sleep_time=1
    echo sleeping "$sleep_time" 
    ${pkgs.coreutils-full}/bin/sleep "$sleep_time"
    echo slept for "$sleep_time"
    echo restart starting
    ${pkgs.systemd}/bin/systemctl restart wireguard_server_start.service
    echo restart done
    '';
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    # requires = ["podman.service" "podman.socket"];
    after = ["default.target" "nm-online.service" "network-online.target" "firewall.service" "time-set.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; 
    };
  };

  nix.settings.trusted-users = [leUser];

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/vda";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "do-nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  sops.defaultSopsFile = ./secrets/secrets.yaml;
  sops.defaultSopsFormat = "yaml";
  # this has to be available when booting, so watch for mount sequence
  # sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.age.keyFile = "/etc/sops/age/keys.txt";
  sops.secrets."yeltnar_nebula_id_rsa" = {
    # set path in file for nebula
    # path = "/var/yeltnar-nebula/id_rsa";
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  # moved to generic

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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users."${leUser}" = {
    isNormalUser = true;
    description = leUser;
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [];
    initialHashedPassword = "$y$j9T$2qm7KFnheAT0Ydn6.B6gy/$yQqev5ru7b2.qHwt4Kw4zNGAwwFB3Lwm5o8TUfnjXq8";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    home-manager

    neovim
    clang # needed to compile c # used in nvim 
    ripgrep # nvim search 
    lua-language-server
    # nixd
    tmux
    tree
    fzf

    jq
    yq
    openssl
    curl
    git
    dig
    lazygit
    nebula
    podman-compose
    borgbackup

    sops
    age
    rclone 
  ];

  programs.neovim = {
    enable = true; 
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
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

  system.activationScripts.binbash = {
    deps = ["binsh"];
    text = ''
      if [ ! -e "/bin/bash" ]; then
      	ln -s /bin/sh /bin/bash
      fi
    '';
  };

  # this allows any user (not just user who mounted) to access fuse (rclone) files 
  environment.etc = {
    "fuse.conf".text = ''
    user_allow_other
    '';
  };

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
  networking.firewall.allowedUDPPorts = [ 
    # allow nebula 
    4242
  ];
  networking.firewall.interfaces."nebula1" = { 
    allowedUDPPorts = [ 
      # allow nebula DNS
      53
    ];
    allowedTCPPorts = [
      # allow nebula DNS
      53
    ];
  };

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
