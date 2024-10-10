with (import <nixpkgs> { 
    config.allowUnfree = true;
});
mkShell {
  buildInputs = [
    nbd
    # nbdkit # TODO add this from FS
  ];
  shellHook = ''
  	# nbd-server 9999 /tmp/_rm/to_squash.sqsh; 
	nbdkit memory 1G
	sudo nbd-client localhost /dev/nbd14;
	bash;
	exit;
  '';
}

