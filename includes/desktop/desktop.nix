# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  lib, 
  ...
}: {

  options.services.desktop_environment.selection = lib.mkOption {
    type = lib.types.enum [
      "gnome"
      "cosmic"
      "none"
    ];
    default = "none";
    description = "pick desktop";
  };

  imports = [
    ../yeltnar_dev.nix
    ./gnome.nix
    ./cosmic.nix
    ./generic.nix 
  ];
}
