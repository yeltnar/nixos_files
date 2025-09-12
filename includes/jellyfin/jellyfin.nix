# man systemd-socket-proxyd
{
  # config,
  pkgs,
  lib,
  ...
}: let 
in {

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.jellyfin = {
    allowedTCPPorts = [
      8096
    ];
    use_run_env = true;
    backup_restore = true;
  };

  # custom.compose.user.testme2 = {};
  # custom.compose.system.testme2 = {};

}
