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
      Unit = "ntfy_report_ip.service";
    };
  };

  systemd.services."ntfy_report_ip" = {
    script = ''
      env;
      # mkdir -p /home/drew/cron
      # export bashrc_folder=/home/drew/playin/custom_bashrc;
      # /home/drew/playin/custom_bashrc/bin/ntfy_report_ip >/home/drew/cron/ntfy_report_ip 2>/home/drew/cron/ntfy_report_stderr
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "drew";
    };
  };
}
