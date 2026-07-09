# man systemd-socket-proxyd
{
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose."agent-api-wrapper" = {
    allowedTCPPorts = [
      3010
    ];
    git_server_uri = "https://codeberg.org";
    git_user = "andbrant";
    # files_to_backup="config";
    backup_restore = false;
    linger = true;
  };

}
