# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.wireguard_server = {
    allowedTCPPorts = [
      51820
    ];
    files_to_backup="data allocation.txt";
    linger = true;
    use_run_env = false;
    test_string = "All tunnels are now active";
  };

}
