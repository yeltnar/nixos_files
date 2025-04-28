{ pkgs, ... }:
pkgs.writeShellScriptBin "hoppscotch" ''
  open "${pkgs.hoppscotch}/Applications/Hoppscotch.app"
''
