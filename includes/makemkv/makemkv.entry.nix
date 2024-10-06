{
  config,
  pkgs,
  ...
}: let
  a = "";
  makemkvDrew = (pkgs.libsForQt5.callPackage /home/drew/playin/nixos_files/includes/makemkv/makemkv.nix { }).overrideAttrs {
      version = "1.17.7";
  };
in {
  environment.systemPackages = with pkgs; [
    # FYI https://nixos.org/guides/nix-pills/13-callpackage-design-pattern 
    # (callPackage /home/drew/playin/nixos_files/includes/makemkv/makemkv.nix { })
    makemkvDrew
  ];
}
