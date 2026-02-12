# man systemd-socket-proxyd
{
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.triliumnotes = {
    allowedTCPPorts = [
      7080
    ];

    super_user_clone = true; # need so restore can start
    super_user_restore = true;
    super_user_start = false;
    super_user_backup_timer = true;
    super_user_backup = true;

    test_string = "Listening on port";
    enable_clone_service = true;
    use_run_env = false;
    backup_restore = true;
    files_to_backup="trilium-data";
    linger = true;
    # backups_to_keep = "--keep-daily=2";
  };

}
