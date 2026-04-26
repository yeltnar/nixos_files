{
  description = "mealie-flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };

      my_packages = with pkgs; [
        podman-compose
        podman 
      ];

      # Path matching your established structure
      container_data_dir = "/home/drew/playin/mealie/data";
      
      compose_file = builtins.toFile "compose.yaml" ''
        services:
          mealie:
            image: ghcr.io/mealie-recipes/mealie:v3.16.0
            container_name: mealie
            restart: always
            ports:
                - "9925:9000"
            deploy:
              resources:
                limits:
                  memory: 1000M
            volumes:
              # Updated to match your volume attachment method
              - ${container_data_dir}:/app/data/
            environment:
              ALLOW_SIGNUP: "false"
              PUID: 1000
              PGID: 1000
              TZ: America/Anchorage
              BASE_URL: https://mealie.yourdomain.com
      '';

      mealiePkg = pkgs.writeShellApplication {
        name = "mealie_app";
        runtimeInputs = my_packages;
        text = ''
          # Create and set permissions for the volume path before starting
          mkdir -p ${container_data_dir}
          chmod 777 ${container_data_dir}
          podman-compose -f ${compose_file} up
        '';
      };

      mealieApp = {
        type = "app";
        program = "${mealiePkg}/bin/mealie_app";
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

      pwd = {
        type = "app";
        program = "${pkgs.writeShellScript "s" ''
        echo pkg ${mealiePkg}
        echo compose_file ${compose_file}
        ''}";
      };

    in
    {
      apps.${system} = {
        default = mealieApp;
        mealie = mealieApp;
        shell = shell;
        pwd = pwd;
      };
    };
}