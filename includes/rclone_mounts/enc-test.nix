{ config, pkgs, ... }:{
  systemd.mounts = with pkgs.lib.strings; [
    {
      requires = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      what = ":crypt:";
      where = "/tmp/rclone-crypt-test/mount";
      type = "rclone";
      options = concatStrings (intersperse "," [ 
        "allow-other=true"
        "vfs-cache-mode=full"
        "nofail"
      ]);
      mountConfig = {
        EnvironmentFile = pkgs.writeTextFile {
          name = "enc-test.env";
          text = ''
            RCLONE_CRYPT_PASSWORD="R9E5UmqHzpjKbNvlXo0kZjsNTzdBNe4bSjpILa-uDu2qrMPTuPY"
            RCLONE_CRYPT_PASSWORD2="UjwgXEbTm_s7iPT94EbkkMd9483JwSzJOatqzUSDgPgFkfnxQoM"
            RCLONE_CRYPT_REMOTE="/tmp/rclone-crypt-test/remote"
          '';
        };
      };
    }
  ];

  # Make sure the local directory for the encrypted files and the
  # mount point for the decrypted files exist.
  systemd.tmpfiles.rules = [
    "d /var/lib/rclone/local-data 0755 root root"
    "d /mnt/rclone-encrypted 0755 root root"
    "d /var/cache/rclone 0755 root root"
    "d /tmp/rclone-crypt-test/mount 0755 root root"
    "d /tmp/rclone-crypt-test/remote 0755 root root"
  ];
}

