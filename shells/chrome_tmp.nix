# simple.nix
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    google-chrome
  ];
  shellHook = ''
  	google-chrome-stable --user-data-dir=/tmp/chrome-user-data; exit; 
  '';
}

