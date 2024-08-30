{ pkgs, ... }:
pkgs.writeShellScriptBin "chrome-nix-tmp" ''
	nix-shell ~/playin/nixos_files/shells/chrome_tmp.nix; 
	exit;
''

