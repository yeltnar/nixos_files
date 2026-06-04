{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    sops-nix = { 
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
  };

  outputs = { self, nixpkgs, nixpkgs_25_11, sops-nix, ... } @ inputs: 
  let
    nixpkgs = nixpkgs_25_11;
    system = "x86_64-linux";
    config = self.config;

    pkgs = import nixpkgs {
    	inherit system;

	    config = {
		    allowUnfree = true; 
	    };
    };
  in 
  {
    nixosConfigurations = {
      drew-lin-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system inputs; };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
