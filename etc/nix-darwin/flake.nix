{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-24.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages = with pkgs; 
        [ 
          ( import ./open-hoppscotch.nix { inherit pkgs; } )
          neovim
          # podman # can't get virt going with nix-darwin
          podman-compose
          podman-desktop
          nixd
          openssh
          sops
          age # for sops encryption 
          jq
          # yq
          yq-go
          tldr
          lima

          # for OpenAPI language server
          spectral-language-server

          lua-language-server
        ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#drew-mbp
    darwinConfigurations."drew-mbp" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
