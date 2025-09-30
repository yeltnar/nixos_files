# man systemd-socket-proxyd
{
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.jellyfin = {
    allowedTCPPorts = [
      8096
    ];
    files_to_backup="config";
    linger = true;
  };

}
