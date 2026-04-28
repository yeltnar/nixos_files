{
  description = "postman";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Adjust to "aarch64-linux" or "aarch64-darwin" if needed
      pkgs = import nixpkgs { inherit system; };

      # This function holds your logic and accepts overrides
      mkRustfs = { 
        use_docker ? false, 
        storage_port ? "9000", 
        ui_port ? "9001" 
      }: 
      let
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
                - "${storage_port}:9000"
                - "${ui_port}:9001"
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

        rustfsPkg = pkgs.writeShellApplication {
          name = "my_app";
          runtimeInputs = my_packages;
          text = ''
            echo "use_docker: ${if use_docker then "true" else "false"}"
            echo "storage_port: ${storage_port}"
            echo "ui_port: ${ui_port}"
            mkdir -p ${container_data_dir}
            chmod 777 ${container_data_dir}
            ${runner_command} -f ${compose_file} up
          '';
        };
      in {
        pkg = rustfsPkg;
        app = {
          type = "app";
          program = "${rustfsPkg}/bin/my_app";
        };
      };

      # Generate the default versions for this flake
      defaultOutput = mkRustfs {};
      miniOutput = mkRustfs { 
        use_docker=true;
        storage_port="9002";
        ui_port="9003";
      };

      pwd = {
        type = "app";
        program = "${pkgs.writeShellScript "s" ''
        echo pkg ${defaultOutput.pkg}
        ''}";
      };

    in
    {
      # Expose the builder function so other flakes can call it
      lib.mkRustfs = mkRustfs;

      apps.${system} = {
        default = defaultOutput.app;
        rustfs = defaultOutput.app;
        mini = miniOutput.app;
        pwd = pwd;
      };

      packages.${system} = {
        default = defaultOutput.pkg;
        rustfsPkg = defaultOutput.pkg;
      };
    };
}
