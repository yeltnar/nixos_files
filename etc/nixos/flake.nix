{
  description = "Merged NixOS systems flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    # nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

  };

  outputs = inputs@{ self, nixpkgs, ... }:
  let
    sops-nix = inputs."sops-nix";
    system = "x86_64-linux";
    aarch64System = "aarch64-linux";
    config = self.config;

    pkgs = import nixpkgs {
      inherit system;

      config = {
        allowUnfree = true;
      };
    };

    aarch64Pkgs = import nixpkgs {
      system = aarch64System;

      config = {
        allowUnfree = true;
      };
    };
  in
  {
    nixosConfigurations = {
      build-image = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./build-image/configuration.nix
        ];
      };

      drew-lin-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system inputs; };

        modules = [
          ./desktop/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      do-nixos = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./digital-ocean/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      drew-lin-lap = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system pkgs inputs; };

        modules = [
          ./laptop/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      mac-vm = nixpkgs.lib.nixosSystem {
        specialArgs = { system = aarch64System; };

        modules = [
          ./mac_vm/configuration.nix
          # (import inputs.wedding_site.cfg ( {inherit config; inherit pkgs; }))
          # sops-nix.nixosModules.sops
        ];
      };

      minimal = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./minimal-image/configuration.nix
        ];
      };

      nixos2 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./nixos2/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixos3 = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./nixos3/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };

      nixos-testing = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system inputs; };

        modules = [
          ./proxmox_vm/configuration.nix
          # (import inputs.wedding_site.cfg ( {inherit config; inherit pkgs; }))
          sops-nix.nixosModules.sops
        ];
      };

      router-nixos-vm = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit system; };

        modules = [
          ./router-nixos-vm/configuration.nix
          sops-nix.nixosModules.sops
        ];
      };
    };
  };
}
