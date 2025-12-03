command="build"
export NIX_SSHOPTS='-t'
flake="do-nixos"
host="do-nixos"
NIX_SSHOPTS='-t'
nixos-rebuild "$command" --flake .#"$flake" --target-host "$host" --use-remote-sudo
