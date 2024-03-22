{
  config,
  pkgs,
  ...
}: {
  systemd.timers."hello-world" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "1m";
      Unit = "hello-world.service";
    };
  };

  systemd.services."hello-world" = {
    script = ''
      set -eu
      ${pkgs.coreutils}/bin/echo "$(date)" > /tmp/hello_world.log
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
