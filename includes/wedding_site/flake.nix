{
  description = "wedding site flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs } @ args:
  let
    # pkgs = nixpkgs.legacyPackages."x86_64-linux";
    # system = "x86_64-linux";
    # config = self.config;
  in{
    lib.myModule = ./wedding_site.nix;
    cfg = ./wedding_site.nix; 
  };
}
