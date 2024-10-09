with (import <nixpkgs> { 
    config.allowUnfree = true;
});
let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixpkgs-unstable) { config.allowUnfree = true; };
in
mkShell {
  buildInputs = [
    unstable.google-chrome
  ];
  shellHook = ''
  	# TODO download this deb in distrobox, and install 
  	# https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  	google-chrome-stable --user-data-dir=/tmp/chrome-user-data; exit; 
  '';
}

