# simple.nix
with (import <nixpkgs> { 
    config.allowUnfree = true;
});
mkShell {
  buildInputs = [
   (pkgs.libsForQt5.callPackage /home/drew/playin/nixos_files/includes/makemkv/makemkv.nix { }) 
  ];
  shellHook = ''
  	makemkv; exit; 
  '';
}

