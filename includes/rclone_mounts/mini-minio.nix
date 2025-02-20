{ pkgs, ...}:
let
  s3-access-key-id=
  ; 
  s3-secret-access-key=
  ;
  s3-endpoint="https://minio-db.h.lan";
  s3-certificate=
    ;
in {

  # certificate from caddy that adds https
  security.pki.certificates = [ s3-certificate ];

  systemd.mounts = with pkgs.lib.strings; [{
    requires = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    what = ":s3:";
    where = "/mnt/minio";
    type = "rclone";
    options = concatStrings (intersperse "," [ 
      "allow-other=true"
      "s3-provider=Minio"
      "s3-access-key-id=${s3-access-key-id}"
      "s3-secret-access-key=${s3-secret-access-key}"
      "s3-endpoint=${s3-endpoint}"
      "nofail"
    ]);
  }];
}
