{
  description = "fix-music";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
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
              # packages = with pkgs; [ picard chromaprint ];
              packages = with pkgs; [ beets ];
              # shellHook= ''
              #   picard
              # '';
              shellHook= ''
                # this will fix the metadata, and move to artist folder for the same path
                # -d is directory... this is a global flag
                # -m is move
                # -w
                # -a
                if [[ -z "$music_dir" ]]; then
                    echo "music_dir is undefined."
                    read -p "Would you like to use the current directory instead? (y/n): " confirm
                    
                    if [[ "$confirm" == "y" || "$confirm" == "Y" ]]; then
                        music_dir=$(pwd)
                        echo "Using directory: $music_dir"
                    else
                        echo "Exiting."
                        exit 1
                    fi
                fi
                beet -d "$music_dir" import -m -w -a "$music_dir"
                exit
              '';
            };
          }
        );
      }) ["x86_64-linux" "aarch64-darwin"]
    );
  };
}
