{
  description = "google-chrome flake dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs } @ args:
  let
    pkgs = import nixpkgs {
      inherit system;
      config = {
        allowUnfree = true;
      };
    };
    system = "x86_64-linux";
    config = self.config;
  in{
    devShells."${system}".default = pkgs.mkShell {
      packages = with pkgs; [  google-chrome ];
      shellHook= ''
  	    google-chrome-stable --user-data-dir=/tmp/chrome-user-data; exit; 
      '';
    };
  };
}
