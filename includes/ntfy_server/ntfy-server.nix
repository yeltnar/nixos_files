# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: let
  unit_id="ntfy_server";
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/${unit_id}";  
in {

  imports = [ ../../includes/helpers/compose-systemd.nix ];

  # expose to nebula devices only
  networking.firewall.interfaces."nebula1".allowedTCPPorts = [
    8981 
  ];

  custom.compose.ntfy_server = {
    allowedTCPPorts = [
      8981 # TODO move to nebulal only?
    ];
    files_to_backup="ntfy_cache ntfy_config ntfy_log ntfy_var";
    linger = true;
    use_run_env = false;
    test_string = "Listening on";
  };

}
