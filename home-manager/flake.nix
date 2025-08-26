{
  description = "Home Manager configuration of drew";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  }: let
    systems = ["aarch64-linux" "x86_64-linux"];
  in {
    packages = builtins.listToAttrs ( map ( system: {
      name = "${system}";
      value = {
        homeConfigurations."drew" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [./home.nix];
        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
      };
    };}) systems );
  };
}
