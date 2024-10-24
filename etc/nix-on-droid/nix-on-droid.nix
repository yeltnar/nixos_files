{
  config,
  lib,
  pkgs,
  ...
}: let
  unstable =
    import
    (builtins.fetchTarball {
      url = "https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable";
      sha256 = "08fdkjliv286jjn4nnyhsvcs7mmqjxglv9x58bfw61k1qrrmd3w1";
    }) {
      config.allowUnfree = true;
      # config = config.nixpkgs.config;
    };
in {
  # Simply install just the packages
  environment.packages = with pkgs; [
    # User-facing stuff that you really really want to have
    unstable.neovim # or some other editor, e.g. nano or neovim
    #    neovim # or some other editor, e.g. nano or neovim

    # Some common stuff that people expect to have
    #procps
    #killall
    #diffutils
    #findutils
    #utillinux
    #tzdata
    hostname
    man
    gnupg
    gnused
    gnutar
    bzip2
    gzip
    #xz
    zip
    unzip

    curl
    gawk
    git
    gnugrep
    iputils
    lua-language-server
    ncurses
    netcat
    nettools
    openssh
    ps
    tmux
    which
    lazygit
    nixd
    ripgrep
    alejandra
  ];

  # Backup etc files instead of failing to activate generation if a file already exists in /etc
  environment.etcBackupExtension = ".bak";

  # Read the changelog before changing this value
  system.stateVersion = "24.05";

  # Set up nix for flakes
  #nix.extraOptions = ''
  #  experimental-features = nix-command flakes
  #'';

  # Set your time zone
  time.timeZone = "America/Chicago";

  # After installing home-manager channel like
  #   nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.05.tar.gz home-manager
  #   nix-channel --update
  # you can configure home-manager in here like
  #home-manager = {
  #  useGlobalPkgs = true;
  #
  #  config =
  #    { config, lib, pkgs, ... }:
  #    {
  #      # Read the changelog before changing this value
  #      home.stateVersion = "24.05";
  #
  #      # insert home-manager config
  #    };
  #};
}
# vim: ft=nix

