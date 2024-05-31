{ pkgs, ... }:
pkgs.writeShellScriptBin "open" ''
  xdg-open $@;
''