# WARNING # MAKE SURE YOU BACK UP YOUR INITIAL `/etc/nixos/config.nix` # THIS DOES NOT CURRENTLY WORK WITH VM AND LAPTOP BOTH BEING ABLE TO BOOT  
link etc/nixos/configuration.nix to same path on root

link home-manager to ~/.config/home-manager

# homemamanger switch # without `--flake` it will use `~/.config/home-manager`
home-manager switch --flake ~/playin/nixos_files/home-manager/ 


# for btrfs 
follow instructions here [Sep 11, 2024] https://nixos.wiki/wiki/Btrfs
use the `Using configuration.nix from the installer` section
Make sure to *NOT* create a new partition table on the installation drive. 
Make sure to select the correct grub device in the installer.

Also want to add extra flags to the config file
