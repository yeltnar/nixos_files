{ pkgs, lib, ... }:

let
  user = "drew";
  group = "users";
  configDir = "/home/${user}/.config/jellyfin";
  caPath = "${configDir}/rustfs-ca.pem";

  rustfsCa = pkgs.writeText "rustfs-ca.pem" ''
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
    -----END CERTIFICATE-----
  '';
in
{
  # add the ca so the container will consume it
  system.activationScripts.rustfsCaCertificate = lib.stringAfter [ group ] ''
    install -d \
      -m 0755 \
      -o ${user} \
      -g ${group} \
      ${configDir}

    ln -sfn \
      ${rustfsCa} \
      ${caPath}

    chown -h ${user}:${group} \
      ${caPath}
  '';
}
