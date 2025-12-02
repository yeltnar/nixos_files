{
  description = "A very basic flake";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    # sops-nix = { 
      # url = "github:Mic92/sops-nix";
      # inputs.nixpkgs.follows = "nixpkgs";
    # };
    # wedding_site = {
    #   # # can either pick 'url' or the other options 
    #   # url = "../../../includes/wedding_site/";
    #   type = "github";
    #   owner = "yeltnar";
    #   repo = "nixos_files";
    #   dir = "includes/wedding_site";
    #   ref = "main";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  # outputs = { self, nixpkgs, sops-nix, ... } @ inputs: 
  outputs = { self, nixpkgs, ... } @ inputs: 
  let
    system = "aarch64-linux";
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
      nixos-testing = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./configuration.nix
          # (import inputs.wedding_site.cfg ( {inherit config; inherit pkgs; }))
          # sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
