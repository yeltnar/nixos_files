{ 
  config,
  lib,
  pkgs,
  ...
}:
let
  generateService = name: value: 
  let 
    subvolume=name;
    snapshot_dir = ".snapshots";
    snapshot_preserve = "2m 3w 5d 4h";
    snapshot_preserve_min = "6h";
    btrfs_top="/mnt/btrfs_root/";
    config = ''
      # This is a sample btrbk.conf file.
      # It is assumed that the subvolume 'home' exists at the root of the Btrfs filesystem.

      # The `snapshot_dir` specifies where the snapshots will be stored.
      # This path is relative to the `volume`.
      snapshot_dir ${snapshot_dir}

      # `volume` defines the Btrfs filesystem or subvolume to be backed up.
      volume ${btrfs_top}

        # `subvolume` specifies the subvolume to be backed up.
        subvolume ${subvolume}

          # The `snapshot_name` defines the naming convention for snapshots.
          # The default is `@snapshot` but can be customized with a timestamp.
          # snapshot_name home

          snapshot_preserve_min ${snapshot_preserve_min} 
          snapshot_preserve ${snapshot_preserve}
    '';
  config_file = builtins.toFile "btrbk_${subvolume}" "${config}";
  start_command = "btrbk snapshot -c ${config_file} -S"; in 
  {
    name = "btrbk_${name}";
    value = {
      path = with pkgs; [
        btrbk
      ];
      script = start_command;
    };
  };

  generateTimer = name: value: let subvolume=name; in  
  {
    name = "btrbk_${name}";
    value = {
      wantedBy = ["timers.target"];
      requires = ["network-online.target"];
      timerConfig = {
        OnCalendar = "*:0/15"; # every 15 minutes
        Unit = "btrbk_${subvolume}.service";
      };
    };
  };

in{
  options.custom_btrbk = lib.mkOption { default = null; };
 
  # This should maybe be put in different place than where the option is defined
  config.custom_btrbk = {
    # backup volume called 'home' 
    # currently the root of the btrfs mount is hard coded
    home = {};
  };

  # TODO consider moving this to a higher scope 
  config.environment.systemPackages = with pkgs; [ btrbk ];

  config.systemd.services = lib.mkIf (config.custom_btrbk != null) ( lib.listToAttrs ( lib.mapAttrsToList generateService config.custom_btrbk ) );
  config.systemd.timers = lib.mkIf (config.custom_btrbk != null) ( lib.listToAttrs ( lib.mapAttrsToList generateTimer config.custom_btrbk ) );
}
