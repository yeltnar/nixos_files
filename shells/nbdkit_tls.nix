with (import <nixpkgs> { 
    config.allowUnfree = true;
});
mkShell {
  buildInputs = [
    nbd
    # libnbd
    (pkgs.callPackage /home/drew/playin/nixos_files/includes/nbdkit/nbdkit.nix { })
  ];
  shellHook = ''
  	# nbd-server 9999 /tmp/_rm/to_squash.sqsh; 
	nbdkit --exit-with-parent memory 10G & # easy cleanup 
	server_pid="$!"  
	sudo nbd-client localhost /dev/nbd0;
        sudo mkfs.btrfs /dev/nbd0
	mkdir -p /tmp/nbd_btrfs
	sudo mount /dev/nbd0 /tmp/nbd_btrfs
	sudo chown drew:100 /tmp/nbd_btrfs
	echo "saved pid is $server_pid";
	bash;
	sudo umount /tmp/nbd_btrfs
	sudo nbd-client -d /dev/nbd0;
	echo " killing $server_pid";
	kill -9 "$server_pid";
	exit;
  '';
}

