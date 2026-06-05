{
  description = "Run Azure CLI via Nix on x86_64-linux";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      pkgs = import nixpkgs { system = "x86_64-linux"; };
    in
    {
      apps.x86_64-linux.default = {
        type = "app";
        program = "${pkgs.writeScriptBin "azure-shell" ''
          #!${pkgs.bashInteractive}/bin/bash
          export PATH="${pkgs.azure-cli}/bin:$PATH"
          echo "⚡ Dropping you into an x86_64-linux bash shell with azure-cli..."
          exec ${pkgs.bashInteractive}/bin/bash --login
        ''}/bin/azure-shell";
      };
    };
}