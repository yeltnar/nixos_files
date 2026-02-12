# man systemd-socket-proxyd
{
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.triliumnotes = {
    allowedTCPPorts = [
      7080
    ];
    test_string = "Listening on port";
    enable_clone_service = true;
    use_run_env = false;
    backup_restore = true;
    files_to_backup="trilium-data";
    linger = true;
    # backups_to_keep = "--keep-daily=2";
  };

}
