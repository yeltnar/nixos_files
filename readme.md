# WARNING # MAKE SURE YOU BACK UP YOUR INITIAL `/etc/nixos/config.nix` # THIS DOES NOT CURRENTLY WORK WITH VM AND LAPTOP BOTH BEING ABLE TO BOOT  
link etc/nixos/configuration.nix to same path on root

link home-manager to ~/.config/home-manager

# homemamanger switch # without `--flake` it will use `~/.config/home-manager`
home-manager switch --flake ~/playin/nixos_files/home-manager/ 
