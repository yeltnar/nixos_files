{
  config,
  pkgs,
  lib, 
  ...
}:
let 
    desktop_environment = config.services.desktop_environment.selection;
in {

  # config for all options 
  config = lib.mkIf ( "none" != desktop_environment ) {

    fonts = { 
      enableDefaultPackages = true;
      packages = with pkgs; [(
        nerd-fonts._0xproto
      )];
      # fontconfig = {
      #   defaultFonts = {
      #
      #   };
      # };
    };

    # Enable CUPS to print documents.
    services.printing.enable = true;

    # Enable sound with pipewire.
    # sound.enable = true # removed at request of nixos-rebuild;
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      jack.enable = true;
      wireplumber.enable = true;

    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.drew = {
      packages = with pkgs; [
        librewolf
        firefox
        vlc
        vscodium

        # tool to view audio info specifically around xrun for cutting out sound
        # qjackctl

        # ffmpeg based video editor
        # losslesscut-bin
        # foss video editor 
        # kdenlive
      ];
    };

    # List packages installed in system profile. To search, run:
    # $ nix search wget
    environment.systemPackages = with pkgs; [

      ( import ../open.nix { inherit pkgs; } )
      ( import ../chrome-nix-tmp.nix { inherit pkgs; } )
         
      xclip
      ghostty
      chafa
      borgbackup
    ];
    
    # Enable the X11 windowing system.
    services.xserver.enable = true;
    services.xserver.excludePackages = [pkgs.xterm];

    # Configure keymap in X11
    services.xserver = {
      xkb = {
        layout = "us";
        variant = "";
      };
    };

    # system.activationScripts.code_symlink = {
    #   text = ''
    #     text_to_add='alias code="codium"';
    #     text_to_check='# code_alias_done';
    #
    #     # create if not there
    #     if [ ! -e /home/drew/.bash_profile ]; then
    #       touch /home/drew/.bash_profile;
    #     fi
    #
    #     test_str=$(cat /home/drew/.bash_profile | grep "$text_to_check");
    #
    #     if [ -z "$test_str" ]; then
    #       echo "$text_to_check" >> /home/drew/.bash_profile;
    #       echo "$text_to_add" >> /home/drew/.bash_profile;
    #     fi
    #   '';
    # };

  };
}
