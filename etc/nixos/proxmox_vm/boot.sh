command="boot"
NIX_SSHOPTS='-t'
nixos-rebuild "$command" --flake .#nixos-testing --target-host nixos --use-remote-sudo
