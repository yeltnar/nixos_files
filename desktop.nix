# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
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
    ./includes/yeltnar_dev.nix
  ];

  fonts = { 
    enableDefaultPackages = true;
    packages = with pkgs; [(
      nerdfonts.override { fonts = [ "BitstreamVeraSansMono" ]; }  # may need to change to "BitstreamWeraSansMono" 
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

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.drew = {
    packages = with pkgs; [
      librewolf
      firefox
      vlc
      vscodium

      # ffmpeg based video editor
      # losslesscut-bin
      # foss video editor 
      # kdenlive
    ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [

    ( import ./includes/open.nix { inherit pkgs; } )
    ( import ./includes/chrome-nix-tmp.nix { inherit pkgs; } )
       
    xclip
    ghostty
  ];

  services.xserver.excludePackages = [pkgs.xterm];
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
}
