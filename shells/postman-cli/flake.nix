{
  description = "Postman CLI wrapper using writeShellApplication";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      setup_env = ''
          export NPM_CONFIG_PREFIX="$HOME/.npm-global"
          export PATH="$NPM_CONFIG_PREFIX/bin:$PATH"

          if ! command -v postman &> /dev/null; then
            echo "postman-cli not found. Installing to $NPM_CONFIG_PREFIX..."
            npm install -g postman-cli
          fi
      '';

      postman-app = pkgs.writeShellApplication {
        name = "postman-wrapper";
        runtimeInputs = with pkgs; [
          nodejs
          steam-run
          coreutils
        ];
        text = ''
          ${setup_env}

          echo you can now run postman cli
          # get shell with FHS... TODO there has to be a better way
          exec steam-run bash

        '';
      };

      postman_cli = {
        type = "app";
        program = "${postman-app}/bin/postman-wrapper";
      };

      worx_tests-app = pkgs.writeShellApplication {
        name = "test";
        runtimeInputs = with pkgs; [
          nodejs
          steam-run
          coreutils
        ];
        text = ''
          ${setup_env}
          # exec vim run_postman.env 
          # shellcheck disable=SC1091
          # shellcheck disable=SC1090
          source ~/worx-ai/playin/run_postman.env 
          export POSTMAN_ENV=dev-production
          exec steam-run bash ~/worx-ai/playin/run_postman.sh 
        '';
      };

      worx_tests = {
        type = "app";
        program = "${worx_tests-app}/bin/test";
      };

    in
    {
      apps.${system} = {
        default = postman_cli;
        postman_cli = postman_cli;
        worx_tests = worx_tests;
      };
    };
}