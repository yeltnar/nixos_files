{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    sops-nix = { 
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, sops-nix, ... } @ inputs: 
  let
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
        specialArgs = { inherit system; };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
