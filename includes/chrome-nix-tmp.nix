{ pkgs, ... }:
pkgs.writeShellScriptBin "chrome-nix-tmp" ''
	export NIXPKGS_ALLOW_UNFREE=1;
	nix-shell ~/playin/nixos_files/shells/chrome_tmp.nix; 
	exit;
''

