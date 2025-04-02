{
  description = "google-chrome flake dev shell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs } @ args: { 
    devShells = builtins.listToAttrs ( 
      map ( system: {
        name = "${system}";
        value = (
          let
            pkgs = import nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
              };
            };
            # config = self.config;
          in {
            default = pkgs.mkShell {
              packages = with pkgs; [  google-chrome ];
              shellHook= ''
                data_path=$HOME/tmp/chrome-user-data
                mkdir -p $data_path
                google-chrome-stable --user-data-dir=$data_path; exit; 
              '';
            };
          }
        );
      }) ["x86_64-linux" "aarch64-darwin"]
    );
  };
}
