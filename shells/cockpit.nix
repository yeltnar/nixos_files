with (import <nixpkgs> { 
    config.allowUnfree = true;
});
let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable) { config.allowUnfree = true; };
in
mkShell {
  buildInputs = [
    unstable.cockpit
  ];
}

