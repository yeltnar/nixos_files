{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
  };

  # outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ... } @ inputs: 
  outputs = { self, nixpkgs, ... } @ inputs: 
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
      router-nixos-vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
