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

          programs.neovim = {
            enable = true;
            # package = unstable.neovim-unwrapped;
            package = pkgs.neovim-unwrapped;
            defaultEditor = true;
            vimAlias = true; 
            viAlias = true; 
          };

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
          ];

          # 1. Place the User CA public key file in /etc/ssh/user_ca.pub
          environment.etc = {
            "ssh/user_ca.pub".text = ''
              ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC4kX6s7x81tN3woXjXJHGvIQALqKS7RN6sj7N3G+euC90xztjlGyQ1rsKcAKbq94Nf4l9ZN4dO5TsTW30SzabNWzo+jEsyUWYbTK2P0NhakrY5VIGyLx7SA5BQwJvTIlor9mbtL2rwdAcuTnPz8ikaRg+OvNt9B6Qh3OM/TxMVg5sVIDFkBUx9G8G6jl9Os9kgj3FSeAHcawoWMV/PLULc+Jq8X27+Ze6QcGtxSGIlfoqGiDzLnB6Yuuo8+KuUrI+1TRkaF6zZnIuGEausctjDaODBsTdGo5nWNbo+9q5ZHHiJ52EP3YFiIj2jnVOpxz4FKwaisOC8MuV0ewodN9Mz8IZeN2Kqu0r81CgKDa0LluVGHAXfVZr8fIUSHdFfyNVzXP+IffUMs1/AKu670GpRildNiyjSM6DIouZm4ojgX/IKZTBygYLrYxXgSNC4AsG7P1ZCTfKvy2mw8/VHZt1ddpaJcTiqtx5Ck91tcRDO0ATIGSBN2xhM13N9Iyu2TiIfip5ZLAgmV5BOBgONb2FzE/KsXAxD5TcRhGr8OHXI/rIJQtMCbXy7Kg3D/b5ngq1IRo5I85zN/Y8dRqPBKj0fguxJlC+pOrwRdIyUthbUvUhBvUXwrdCCvWj9Bh5ub2rdu62/unC1Wbw2yPuFlBjqtO8kjxsV5Ta8McUjA40BIQ== user_ca
            '';
          };
          
          # 2. Tell the OpenSSH server (sshd) to trust the CA key
          services.openssh.extraConfig =
            ''
            TrustedUserCAKeys /etc/ssh/user_ca.pub
            '';

        })
      ];
    };
    
    # Define an easier way to build the ISO image
    packages.${system}.iso = self.nixosConfigurations.bcachefs-installer.config.system.build.isoImage;
  };
}
