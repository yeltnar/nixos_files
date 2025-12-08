# add the -I ... to allow for building the install without needing flakes
nix build -o myresult .#iso -I nixpkgs=channel:nixos-unstable
