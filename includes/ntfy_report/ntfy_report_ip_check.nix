{
  config,
  pkgs,
  ...
}: let
  unit_id = "ntfy_report_ip_check"; 
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/${unit_id}";  
  git_uri="https://github.com/yeltnar/device_report_ntfy_check.git";
in {

  imports = [ ../nm-online.service.nix ];

  sops.secrets."local.json" = {
    owner = "drew";
    # path = backup_env_file;
    sopsFile = ./secrets.yaml;
  };
  
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
      git clone "${git_uri}" ${code_dir};
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "${unit_id}";
    };
    onSuccess = [
      "ntfy_report_ip_check.timer"
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
    requires = ["nm-online.service" "podman.service" "podman.socket"];
    path = with pkgs; [
      podman
      podman-compose
    ];

    script = ''
      PATH="$PATH:${pkgs.podman}/bin";

      # we want a real file, not a link so we replace it every time 
      rm -rf "${code_dir}/config/local.json";
      cat ${config.sops.secrets."local.json".path} > "${code_dir}/config/local.json";

      podman-compose up
    '';
    serviceConfig = {
      Type = "oneshot";
      # User = "drew";
      WorkingDirectory = "${code_dir}";
    };
    unitConfig = {
      ConditionPathExists = [
        "${code_dir}"
      ];
    };
  };
}
