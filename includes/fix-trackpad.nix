{ pkgs, ... }:
let script = ''
  sudo modprobe -r psmouse && sudo modprobe psmouse
'';
in { 
	environment.systemPackages = [ 
		(pkgs.writeShellScriptBin "fix-trackpad" script)
	];
	# TODO: add systemctl to do this after resume 
}

