{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    # FYI https://nixos.org/guides/nix-pills/13-callpackage-design-pattern 
    (callPackage ./nbdkit.nix { })
  ];
}
