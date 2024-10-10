with (import <nixpkgs> { 
    config.allowUnfree = true;
});
mkShell {
  buildInputs = [
    nbd
  ];
  shellHook = ''
  	nbd-server 9999 /tmp/_rm/to_squash.sqsh; 
	sudo nbd-client localhost 9999 /dev/nbd0;
	bash;
	exit;
  '';
}

