{ lib, config, ... }:
{
  # they also had something for an ssd and intel cpu
  # https://github.com/NixOS/nixos-hardware/blob/master/lenovo/thinkpad/l13/default.nix
  services.xserver.wacom.enable = lib.mkDefault config.services.xserver.enable;
}

