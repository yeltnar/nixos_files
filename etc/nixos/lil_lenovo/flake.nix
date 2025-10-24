{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    # sops-nix = { 
    #   url = "github:Mic92/sops-nix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

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
      lil_lenovo = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };
        modules = [
          ./configuration.nix
        ];
      };
    };
  };
}
