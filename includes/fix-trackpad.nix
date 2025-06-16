{ pkgs, ... }:
pkgs.writeShellScriptBin "fix-trackpad" ''
  sudo modprobe -r psmouse && sudo modprobe psmouse
''

