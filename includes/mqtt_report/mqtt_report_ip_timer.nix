{
  config,
  pkgs,
  ...
}: {
  systemd.timers."mqtt_report_ip" = {
    wantedBy = ["timers.target"];
    requires = ["network-online.target"];
    timerConfig = {
      OnUnitActiveSec = "2m";
      # start service when timer starts
      OnActiveSec = "0s";
      Unit = "mqtt_report_ip.service";
    };
  };

  systemd.services."mqtt_report_ip" = {
    requires = ["network-online.target"];
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
      gawk
      nettools
      mosquitto
      nebula
    ];

    script = ''
      # env;
      # command -v curl
      # curl https://ip.andbrant.com 2>/dev/null
      # export PATH=$PATH;
      mkdir -p /home/drew/cron
      export bashrc_folder=/home/drew/playin/custom_bashrc;
      /home/drew/playin/custom_bashrc/bin/mqtt_report_ip >/home/drew/cron/mqtt_report_ip 2>/home/drew/cron/mqtt_report_stderr
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "drew";
    };
    unitConfig = {
      ConditionPathExists = [
        "/home/drew/playin/custom_bashrc/gitignore/mqtt_endpoint"
        # "/home/drew/playin/custom_bashrc/gitignore/mqtt_token"
      ];
    };
  };
}
