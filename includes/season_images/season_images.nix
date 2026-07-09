# man systemd-socket-proxyd
{
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.season_images = {
    allowedTCPPorts = [
      8111
    ];
    # files_to_backup="config";
    backup_restore = false;
    linger = true;
    test_string = "Application startup complete";
  };

}
