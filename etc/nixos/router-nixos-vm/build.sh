command="build"
export NIX_SSHOPTS='-t'
flake="router-nixos-vm"
host="router-nixos-vm"
nixos-rebuild "$command" --flake .#"$flake" --target-host "$host" --sudo
