{
  config,
  pkgs,
  ...
}: {
  systemd.timers."hello-world" = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "2m";
      Unit = "ntfy_report_ip.service";
    };
  };

  systemd.services."ntfy_report_ip" = {
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/drew";
      }
      // config.networking.proxy.envVars;

    path = with pkgs; [
      curl
      git
    ];

    script = ''
      # env;
      command -v curl
      curl https://do.andbrant.com 2>/dev/null
      export PATH=$PATH;
      mkdir -p /home/drew/cron
      export bashrc_folder=/home/drew/playin/custom_bashrc;
      /home/drew/playin/custom_bashrc/bin/ntfy_report_ip >/home/drew/cron/ntfy_report_ip 2>/home/drew/cron/ntfy_report_stderr
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "drew";
    };
  };
}
