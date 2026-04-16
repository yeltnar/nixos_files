
{
  description = "vscode-fhs";

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
      lib = nixpkgs.lib;

      my_packages = with pkgs; [
        vscode-fhs
      ];

      # Create a wrapper script that acts as the 'app'
      runApp = pkgs.writeShellApplication {
        name = "run-mulesoft-app";
        runtimeInputs = my_packages;
        text = ''
          code
        '';
      };

      main = {
        type = "app";
        program = "${runApp}/bin/run-mulesoft-app";
      };

      # Create a wrapper script that acts as the 'app'
      runBash = pkgs.writeShellApplication {
        name = "shell";
        runtimeInputs = my_packages;
        text = ''
          date
          exec bash
        '';
      };

      shell = {
        type = "app";
        program = "${runBash}/bin/shell";
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
        default = main;
        vscode = main;
        shell = shell;
      };
    };
}

