#!/usr/bin/env bash
#
# I believe there are a few ways to do this:
#
#    1. My current way, using a minimal /etc/nixos/configuration.nix that just imports my config from my home directory (see it in the gist)
#    2. Symlinking to your own configuration.nix in your home directory (I think I tried and abandoned this and links made relative paths weird)
#    3. My new favourite way: as @clot27 says, you can provide nixos-rebuild with a path to the config, allowing it to be entirely inside your dotfies, with zero bootstrapping of files required.
#       `nixos-rebuild switch -I nixos-config=path/to/configuration.nix`
#    4. If you uses a flake as your primary config, you can specify a path to `configuration.nix` in it and then `nixos-rebuild switch —flake` path/to/directory
# As I hope was clear from the video, I am new to nixos, and there may be other, better, options, in which case I'd love to know them! (I'll update the gist if so)

# A rebuild script that commits on a successful build
set -e

# cd to your config dir
nix_cfg_dir="/home/drew/playin/nixos_files";
pushd "$nix_cfg_dir";

# Edit your config
if [ -z $file ]; then
	echo 'file is empty'
	# file="generic_configuration.nix";
fi
echo "file is $file";

if [ -e "$file" ]; then
	$EDITOR "$file"; 
# else
	# echo "file is not found";
	# exit;
fi

# Autoformat your nix files
if [ ! -z $(command -v alejandra) ]; then
  alejandra . >/dev/null
  # echo "ADD BACK ALEJANDRA";
fi

# Shows your changes
git diff -U0 *.nix includes/*.nix

echo "NixOS Rebuilding..."

# Rebuild, output simplified errors, log trackebacks
sudo nixos-rebuild switch &>nixos-switch.log || (cat nixos-switch.log && false)

# Get current generation metadata
current=$(nixos-rebuild list-generations | grep current)

# Commit all changes witih the generation metadata
git commit -am "$current"

# Back to where you were
popd

# Notify all OK!
# notify-send -e "NixOS Rebuilt OK!" --icon=software-update-available
