{
  description = "kdenlive";

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
              packages = with pkgs; [ kdenlive ];
              shellHook= ''
                kdenlive; exit; 
              '';
            };
          }
        );
      }) ["x86_64-linux"]
    );
  };
}
