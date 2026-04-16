
{
  description = "postman";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux"; # Adjust to "aarch64-linux" or "aarch64-darwin" if needed
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
        };
      };

      version = "12.6.4";
      fetchurl = pkgs.fetchurl;
      selectSystem = pkgs.selectSystem;
      stdenvNoCC = pkgs.stdenvNoCC;

      tar = fetchurl {
        name = "postman-${version}.${if stdenvNoCC.hostPlatform.isLinux then "tar.gz" else "zip"}";
        url = "https://dl.pstmn.io/download/version/${version}/${system}";
        hash = selectSystem {
          aarch64-darwin = "sha256-+iPKe3JSqR+3oc9vWFsxPccl/sTvYW70NpW4pv80iSE=";
          aarch64-linux = "sha256-9vJAfXFCoxJcb4AVS0ly5vJYd4ydB1Fb1GNtr6RopXU=";
          x86_64-darwin = "sha256-BqoM2cIsjRaLT6CfQLwN7agaM6Ijo6zYvxcF6wzWIyw=";
          x86_64-linux = "sha256-g3/PjA0MJKJ7oa2x7C+l2FEMN/OIMWQD8OoGtpoa3Wk=";
        };
      };

      lib = nixpkgs.lib;

      my_packages = with pkgs; [
        postman
        newman
      ];

      data_parent_dir="$HOME/tmp/postman_data/nixpkgs";
      postmanApp = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "my_app";
          runtimeInputs = my_packages;
          text = ''
            echo 'flake start'
            mkdir -p "${data_parent_dir}"
            bash -c 'XDG_CONFIG_HOME="${data_parent_dir}" exec postman' >/dev/null 2>&1 &
            echo 'flake done'
          '';
        }}/bin/my_app";
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

      # Create a wrapper script that acts as the 'app'
      t = {
        type = "app";
        program = "${pkgs.writeShellApplication {
          name = "shell";
          runtimeInputs = my_packages;
          text = ''
            exec conda-shell -c "exec ${pkgs.bash}/bin/bash"
          '';
        }}/bin/shell";
      };

      print = {
        type = "app";
        program = "${pkgs.writeShellScript "s" ''
        nix flake show --json ${self}
        ''}";
      };


      workdir = "~/worx-ai/mulesoft/";
    in
    {
      # packages.${system}.default = runApp;

      # Allows you to use 'nix run .'
      apps.${system} = {
        default = postmanApp;
        postman = postmanApp;
        shell = shell;
        t = t;
      };
    };
}

