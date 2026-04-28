
{
  description = "postman";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Adjust to "aarch64-linux" or "aarch64-darwin" if needed
      pkgs = import nixpkgs { inherit system; };

      lib = nixpkgs.lib;

      use_docker = false;

      runner_command = if use_docker then "docker-compose" else "podman-compose";
      # runner_command = "podman-compose";

      runner_packages = with pkgs;
        if use_docker
        then [ docker docker-compose ]
        else [ podman podman-compose ];

      my_packages = with pkgs; [
      ] ++ runner_packages;

      container_data_dir = "/home/drew/playin/rustfs/data";
      
      compose_file = builtins.toFile "compose.yaml" ''
        # default login rustfsadmin/rustfsadmin
        services:
          rustfs:
            image: rustfs/rustfs:latest
            container_name: rustfs
            ports:
              - "9000:9000"
              - "9001:9001"
            volumes:
              # - rustfs-data:/data
              - ${container_data_dir}:/data
            environment:
              - RUSTFS_ACCESS_KEY=user
              - RUSTFS_SECRET_KEY=pass
            stdin_open: true # Corresponds to -i
            tty: true        # Corresponds to -t

        volumes:
          rustfs-data:
      '';

      data_parent_dir="$HOME/tmp/postman_data/nixpkgs";

      rustfsPkg = pkgs.writeShellApplication {
        name = "my_app";
        runtimeInputs = my_packages;
        text = ''
          mkdir -p ${container_data_dir}
          chmod 777 ${container_data_dir}
          ${runner_command} -f ${compose_file} up
        '';
      };

      rustfsApp = {
        type = "app";
        program = "${rustfsPkg}/bin/my_app";
      };

      shell = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "shell";
          runtimeInputs = my_packages;
          text = ''
            exec bash
          '';
        }}/bin/shell";
      };

      print = {
        type = "app";
        program = "${pkgs.writeShellScript "s" ''
        nix flake show --json ${self}
        ''}";
      };

      pwd = {
        type = "app";
        program = "${pkgs.writeShellScript "s" ''
        echo pkg ${rustfsPkg}
        echo compose_file ${compose_file}
        ''}";
      };

    in
    {
      # packages.${system}.default = runApp;

      # Allows you to use 'nix run .'
      apps.${system} = {
        default = rustfsApp;
        rustfs = rustfsApp;
        shell = shell;
        pwd = pwd;
      };
    };
}

