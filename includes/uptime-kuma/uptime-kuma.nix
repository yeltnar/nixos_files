# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}:{
  
  imports = [
    ../helpers/compose-systemd.nix
  ];

  custom.compose.user.uptime-kuma = {
    allowedTCPPorts = [
      4001
    ];
    test_string = "Listening on";
    use_run_env = false;
    backup_restore = true;
  };

}
