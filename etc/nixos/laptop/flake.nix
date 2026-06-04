{
  description = "A very basic flake";

  inputs = {
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    sops-nix = { 
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, ... } @ inputs: 
  let
    system = "x86_64-linux";
    config = self.config;

    # Import unstable Nixpkgs
    unstablePkgs = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true; # Or configure as needed
    };

    pkgs = import nixpkgs {
    	inherit system;

	    config = {
		    allowUnfree = true; 
	    };

      # copy unstable pkg into regular pkgs
      # WARN: use extream caution mixing like this
      overlays = [
        # (final: prev: { hyprshell = unstablePkgs.hyprshell; })
      ];
    };

  in 
  {
    nixosConfigurations = {
      drew-lin-lap = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system pkgs; };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
