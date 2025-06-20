{
  config,
  pkgs,
  ...
}: let
  unit_id = "ntfy_report_ip_check"; 
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/${unit_id}";  
in {

  imports = [ ../nm-online.service.nix ];
  
  systemd.user.services."${unit_id}-git-repo" = {
    path = with pkgs; [
      git
    ];
    description = "${unit_id}-git-repo";
    # requires = ["network-online.target"];
    after = ["nm-online.service"];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    unitConfig = {
      ConditionPathExists = "!${code_dir}";
    };
    script = ''
      mkdir -p ${code_parent_dir}; 
      cd ${code_parent_dir}/; 
      git clone https://github.com/yeltnar/${unit_id};
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "${unit_id}";
    };
    onSuccess = [
      "restore.${unit_id}.service"
    ];
  };

  systemd.user.timers."ntfy_report_ip_check" = {
    wantedBy = ["timers.target"];
    requires = ["nm-online.service"];
    timerConfig = {
      OnUnitActiveSec = "2m";
      # start service when timer starts
      OnActiveSec = "0s";
      Unit = "ntfy_report_ip_check.service";
    };
  };

  systemd.user.services."ntfy_report_ip_check" = {
    requires = ["nm-online.service"];
    environment =
      config.nix.envVars
      // {
        inherit (config.environment.sessionVariables) NIX_PATH;
        HOME = "/home/drew";
      }
      // config.networking.proxy.envVars;

    path = with pkgs; [
      # curl
      # git
      # gawk
      # nettools
      nodejs_24
    ];

    script = ''
      cd /root/playin/device_report_ntfy_check;
      node main.js
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "drew";
    };
    unitConfig = {
      ConditionPathExists = [
        "/home/drew/playin/device_report_ntfy_check"
      ];
    };
  };
}
