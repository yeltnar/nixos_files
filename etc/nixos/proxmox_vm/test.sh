command="test"
export NIX_SSHOPTS='-t'
flake="nixos-testing"
host="nixos"
NIX_SSHOPTS='-t'
nixos-rebuild "$command" --flake .#"$flake" --target-host "$host" --use-remote-sudo
