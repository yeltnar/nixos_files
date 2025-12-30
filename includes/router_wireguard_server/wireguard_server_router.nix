# man systemd-socket-proxyd
{
  config,
  pkgs,
  ...
}:{

  imports = [ ../helpers/compose-systemd.nix ];

  custom.compose.router_wireguard_server = {
    allowedUDPPorts = [
      51820
    ];
    files_to_backup="data allocation.txt";
    linger = true;
    use_run_env = false;
    test_string = "All tunnels are now active";
    backup_restore = true; 

    super_user_clone = true;
    super_user_start = true;
    super_user_restore = true;
    super_user_backup_timer = true;
    super_user_backup = true;
    repo_dir = "wireguard_server";
  };

  # this is my hack to get it to work... I have not been able to find the correct 'after' to get it to work 
  systemd.services.restart_wireguard = {
    script = ''
    sleep_time=1
    echo sleeping "$sleep_time" 
    ${pkgs.coreutils-full}/bin/sleep "$sleep_time"
    echo slept for "$sleep_time"
    echo restart starting
    ${pkgs.systemd}/bin/systemctl restart router_wireguard_server_start.service
    echo restart done
    '';
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    # requires = ["podman.service" "podman.socket"];
    after = ["default.target" "nm-online.service" "network-online.target" "firewall.service" "time-set.target"];
    wants = ["network-online.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true; 
    };
  };
}
