command="boot"
export NIX_SSHOPTS='-t'
flake="do-nixos"
host="do-nixos"
nixos-rebuild "$command" --flake .#"$flake" --target-host "$host" --use-remote-sudo
