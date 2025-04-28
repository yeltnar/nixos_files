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
              packages = with pkgs; [  hoppscotch ];
              shellHook= ''
                open ${pkgs.hoppscotch}/Applications/Hoppscotch.app; exit 
              '';
            };
          }
        );
      # }) ["x86_64-linux" "aarch64-darwin"]
      }) ["aarch64-darwin"]
    );
  };
}
