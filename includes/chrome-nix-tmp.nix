{ pkgs, ... }:
pkgs.writeShellScriptBin "chrome-nix-tmp" ''
	export NIXPKGS_ALLOW_UNFREE=1;
	nix develop /home/drew/playin/nixos_files/shells/chrome; 
	exit;
''

