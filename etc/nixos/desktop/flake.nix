{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";
    sops-nix = { 
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs_25_11.url = "github:nixos/nixpkgs/nixos-25.11";
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
        specialArgs = {
            inherit system; 

            # Passing custom arguments into your modules
            # Instantiate the old nixpkgs for your system and name it 'hyprpkgs'
            nixpkgs_25_11 = import nixpkgs_25_11 {
              inherit system;
              config.allowUnfree = true; # Allow unfree packages if needed
            };

          };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
