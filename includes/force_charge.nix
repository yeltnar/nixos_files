{ pkgs, ... }:
pkgs.writeShellScriptBin "force_charge" ''
 sudo tlp setcharge 80 81;  
''
