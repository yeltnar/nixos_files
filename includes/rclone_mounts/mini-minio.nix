{ pkgs, ...}:
let
  s3-access-key-id=
  ; 
  s3-secret-access-key=
  ;
  s3-endpoint="https://minio-db.h.lan";
  s3-certificate=
    ;

    env_file = pkgs.writeText "mnt-minio.systemd.env" ''
    RCLONE_S3_SECRET_ACCESS_KEY=${s3-secret-access-key}
    RCLONE_S3_ACCESS_KEY_ID=${s3-access-key-id}
    RCLONE_S3_ENDPOINT=${s3-endpoint}
    '';
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
      "nofail"
    ]);
    mountConfig = {
      EnvironmentFile = env_file;
    };
  }];
}
