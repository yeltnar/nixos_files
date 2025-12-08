{
  description = "Minimal NixOS installer with Bcachefs support";

  inputs = {
    # Use a stable channel for the base system
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; 
  };

  outputs = { self, nixpkgs }:
  let
    # The system architecture (change if necessary)
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
    use_gui = false;

    module = 
      if use_gui then 
        "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
      else 
        "${pkgs.path}/nixos/modules/installer/cd-dvd/installation-cd-graphical-calamares-gnome.nix"
      ;
  in
  {
    nixosConfigurations.bcachefs-installer = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [

        module
        # "${nixpkgs}/nixos/modules/installer/cd-dvd/channel.nix"

        # 2. Add the Bcachefs configuration overrides
        ({ config, lib, pkgs, ... }: {

          imports = [
            ../../includes/ssh/ssh_cert.nix 
          ];

          programs.neovim = {
            enable = true;
            # package = unstable.neovim-unwrapped;
            package = pkgs.neovim-unwrapped;
            defaultEditor = true;
            vimAlias = true; 
            viAlias = true; 
          };

          # I don't need a lot of gnome stuff 
          environment.gnome.excludePackages =
            (with pkgs; [
              gnome-tour
              xterm
              epiphany
              totem
              geary
              seahorse
              gnome-music
            ]);

          # Enable Bcachefs support for both kernel module and user tools
          # This automatically includes the bcachefs-tools package and
          # builds the out-of-tree kernel module if needed.
          boot.supportedFilesystems = [ "bcachefs" ];

          # Optionally, enforce the latest kernel for best Bcachefs support
          # This will increase the build time.
          # boot.kernelPackages = pkgs.linuxPackages_latest;

          # Ensure the bcachefs user-space tools are available in the ISO's environment
          environment.systemPackages = with pkgs; [
            bcachefs-tools
            curl
            git
          ];
        })
      ];
    };
    
    # Define an easier way to build the ISO image
    packages.${system}.iso = self.nixosConfigurations.bcachefs-installer.config.system.build.isoImage;
  };
}
