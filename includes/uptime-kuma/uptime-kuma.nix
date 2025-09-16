# man systemd-socket-proxyd
{
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.uptime-kuma = {
    allowedTCPPorts = [
      4001
    ];
    test_string = "Listening on";
    use_run_env = false;
    files_to_backup="data";
    linger = true;
  };

}
