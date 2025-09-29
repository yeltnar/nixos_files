{ 
  pkgs,
  ...
}:
let
  snapshot_dir = ".snapshots";
  snapshot_preserve = "1y 1m 1w 1d 1h";
  subvolume="home";
  config = ''
    # This is a sample btrbk.conf file.
    # It is assumed that the subvolume 'home' exists at the root of the Btrfs filesystem.

    # The `snapshot_dir` specifies where the snapshots will be stored.
    # This path is relative to the `volume`.
    snapshot_dir ${snapshot_dir}

    # `volume` defines the Btrfs filesystem or subvolume to be backed up.
    volume /mnt/btrfs_root/

      # `subvolume` specifies the subvolume to be backed up.
      subvolume ${subvolume}

        # The `snapshot_name` defines the naming convention for snapshots.
        # The default is `@snapshot` but can be customized with a timestamp.
        # snapshot_name home

        snapshot_preserve_min latest 
        snapshot_preserve ${snapshot_preserve}
  '';
  config_file = builtins.toFile "btrbk_${subvolume}" "${config}";
  start_command = "btrbk snapshot -c ${config_file} -S";
in{
  # TODO consider moving this to a higher scope 
  environment.systemPackages = with pkgs; [ btrbk ];
  systemd.services."btrbk_${subvolume}" = {
    path = with pkgs; [
      btrbk
    ];
    script = start_command;
  };
  systemd.timers."btrbk_${subvolume}" = {
    wantedBy = ["timers.target"];
    requires = ["network-online.target"];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "btrbk_${subvolume}.service";
    };
  };
}
