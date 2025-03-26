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

### seting up new remote machine with nebula
_generate keys.txt_
- age-keygen 2>/dev/null | awk '!/#/' > keys.txt

_add new entry to .sops.yaml_

_create new keypair in nebula orchestrator directory for the new machine_
- ssh-keygen -t rsa -m PEM -N "" -q -b 4096 -f id_rsa

_create sops file for new machine_
- sops ./secrets/secrets.yaml
- _add keys.txt content as a key under `sops_key`_
- _add id_rsa private key as a value under `yeltnar_nebula_id_rsa: |`_

_copy the keys.txt content to /etc/sops/age/keys.txt on the new machine_
