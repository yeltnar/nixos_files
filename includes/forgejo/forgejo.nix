# man systemd-socket-proxyd
{ ... }:
{
  imports = [
    ../helpers/compose-systemd.nix
    ../helpers/rustfs-ca.nix
  ];

  custom.compose.forgejo = {
    allowedTCPPorts = [
      3630
      2222
    ];
    compose_file = ''
      services:
        forgejo:
          image: codeberg.org/forgejo/forgejo:15
          container_name: forgejo
          restart: unless-stopped

          environment:
            TZ: America/Chicago
            USER_UID: "1000"
            USER_GID: "1000"

            FORGEJO__database__DB_TYPE: sqlite3
            FORGEJO__server__DOMAIN: localhost
            FORGEJO__server__ROOT_URL: https://forgejo.h.lan/
            FORGEJO__server__HTTP_PORT: "3630"
            FORGEJO__server__SSH_DOMAIN: localhost
            FORGEJO__server__SSH_PORT: "2222"

          ports:
            - "3630:3630"
            - "2222:22"

          volumes:
            - ./forgejo/data:/data
    '';
    files_to_backup="forgejo/data";
    use_run_env = false;
    linger = true;
  };

}
