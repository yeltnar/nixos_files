command="build"
export NIX_SSHOPTS='-t'
flake="minimal"
NIX_SSHOPTS='-t'
nixos-rebuild "$command" --flake .#"$flake" --use-remote-sudo
