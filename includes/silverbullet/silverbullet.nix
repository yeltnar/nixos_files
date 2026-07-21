{ ... }:
{
  imports = [
    ../helpers/compose-systemd.nix
  ];

  custom.compose.silverbullet = {
    compose_file = builtins.readFile ./compose.yaml;
    allowedTCPPorts = [ 3009 ];
    backup_restore = false;
    linger = true;
    use_run_env = false;
  };
}
