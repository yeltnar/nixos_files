command="$1"

if [ -z "$flake" ]; then
  echo "flake is not set; exiting"
  exit 1
fi

if [ -z "$host" ]; then
  echo "host is not set; exiting"
  exit 1
fi

nixos-rebuild "$command" --flake .#"$flake" --target-host "$host" --ask-sudo-password
