# simple.nix
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
    google-chrome
  ];
  shellHook = ''
  	# TODO download this deb in distrobox, and install 
  	# https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  	google-chrome-stable --user-data-dir=/tmp/chrome-user-data; exit; 
  '';
}

