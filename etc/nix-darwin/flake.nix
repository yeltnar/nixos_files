{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    # nixpkgs_unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = { url = "github:homebrew/homebrew-core"; flake = false; };
    homebrew-cask = { url = "github:homebrew/homebrew-cask"; flake = false; };
    homebrew-bundle = { url = "github:homebrew/homebrew-bundle"; flake = false; };
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, homebrew-core, homebrew-cask, homebrew-bundle, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

      system.primaryUser = "drew"; 
      homebrew = {
        enable = true; 
        onActivation = {
          autoUpdate = true; 
           # = true; 
        };
        brews = [
          "podman"
          "qemu"
          "openjdk"
        ];
        casks = [
          "chromium"
          "ghostty"
          "macfuse"
          "vscodium"
          "podman-desktop"
          "nikitabobko/tap/aerospace"
          "kdenlive"
        ];
      };

      nixpkgs.config.allowUnfree = true;

      environment.systemPackages = with pkgs; 
        [ 

          ( import ./open-hoppscotch.nix { inherit pkgs; } )
          # ( import ./open-hoppscotch.nix { pkgs, nixpkgs = nixpkgs-unstable }; )

          neovim
          nvimpager
          podman-compose
          nixd
          openssh
          nebula
          sops
          age # for sops encryption 
          jq
          # yq # dont use this one
          yq-go
          tldr
          lima
          bash # mac bash is dead
          borgbackup
          utm # VM manager. Start with `utm`
          bat

          ffmpeg
          fzf
          gawk
          gnupg
          lazygit
          ripgrep
          rsync
          tmux
          tree
          curl
          
          spectral-language-server # for OpenAPI language server
          lua-language-server

          k9s
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

      # system.activationScripts.setGitMain = {
      system.activationScripts.postActivation = {
        text = ''
          echo "hi $(date)" > /tmp/plz.fmd.log
          git config --file /Users/drew/.gitconfig init.defaultBranch main
          echo "hi $(date)" >> /tmp/plz.fmd.log
        '';
        enable = true;
      };

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#drew-mbp
    darwinConfigurations."drew-mbp" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration 
        # nix-homebrew.darwinModules.nix-homebrew {
        #   nix-homebrew = {
        #     enable = true; 
        #
        #     # run x86 versions on mac 
        #     # enableRosetta = true; 
        #
        #     user = "drew";
        #
        #     taps = {
        #       "homebrew/homebrew-core" = inputs.homebrew-core;
        #       "homebrew/homebrew-cask" = inputs.homebrew-cask;
        #     };
        #
        #     # TODO change this to be false
        #     # mutableTaps = true; 
        #     autoMigrate = true;
        #
        #   };
        # }
      ];
    };
  };
}
