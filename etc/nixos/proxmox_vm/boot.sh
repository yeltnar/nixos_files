command="boot"
export NIX_SSHOPTS='-t'
flake="nixos-testing"
host="nixos"
nixos-rebuild "$command" --flake .#"$flake" --target-host "$host" --use-remote-sudo
