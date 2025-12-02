{
  description = "fastfetch";

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
              packages = with pkgs; [ fastfetch ];
              shellHook= ''
                fastfetch; exit; 
              '';
            };
          }
        );
      }) ["x86_64-linux" "aarch64-darwin"]
    );
  };
}
