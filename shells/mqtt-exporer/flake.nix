{
  description = "mqtt-explorer";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=25.05";
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
              packages = with pkgs; [ mqtt-explorer ];
              shellHook= ''
                mqtt-explorer ; exit ; 
              '';
            };
          }
        );
      }) ["x86_64-linux" "aarch64-darwin"]
      # }) ["aarch64-darwin"]
    );
  };
}
