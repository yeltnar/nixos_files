{ pkgs, config, ...}:
let
  s3-certificate=
  ''
    -----BEGIN CERTIFICATE-----
    MIIBozCCAUqgAwIBAgIRAPZn1/oD/c0M9GhKndrWbmcwCgYIKoZIzj0EAwIwMDEu
    MCwGA1UEAxMlQ2FkZHkgTG9jYWwgQXV0aG9yaXR5IC0gMjAyMSBFQ0MgUm9vdDAe
    Fw0yMTEwMDMwNDIzNDdaFw0zMTA4MTIwNDIzNDdaMDAxLjAsBgNVBAMTJUNhZGR5
    IExvY2FsIEF1dGhvcml0eSAtIDIwMjEgRUNDIFJvb3QwWTATBgcqhkjOPQIBBggq
    hkjOPQMBBwNCAAR4V9bn+bmOJfWlIGkNZyy+FzHCxIZiU3Ko6f+MgY9fbZddVvZU
    +qUMqdj1jOOSHGb2oksfABkhrJAnNcqtafH9o0UwQzAOBgNVHQ8BAf8EBAMCAQYw
    EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUGxw7vsSlsHoIbX3fqTwnH8+8
    Ni0wCgYIKoZIzj0EAwIDRwAwRAIgAPmMzq8t6N9H6wUyxEjYZY870ysKNxtrBrmK
    JmH3busCICZnli09FnPU9/3mt6Kf1AhEF6X3evM+J/P1gEGOqM9u
    -----END CERTIFICATE-----''
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
      "vfs-cache-mode=full"
      "s3-provider=Minio"
      "nofail"
    ]);
    mountConfig = {
      EnvironmentFile = config.sops.secrets."mnt-minio.env".path;
    };
  }];
}
