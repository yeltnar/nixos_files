# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: let
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/caddy-cloud";  
in {
  networking.firewall.allowedTCPPorts = [
    80
    443 
  ];

  # enable lingering so service starts before user logs in
  # users.users.drew.linger = true;

  systemd.services.caddy-cloud-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "caddy-cloud-git-repo";
    requires = ["network-online.target"];
    after = ["default.target" "network-online.target"];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    unitConfig = {
      ConditionPathExists = "!${code_dir}";
    };
    script = ''
      /run/wrappers/bin/su - drew -s /bin/sh -c 'cd ${code_parent_dir}/; git clone https://github.com/yeltnar/caddy-cloud';
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "caddy-cloud";
      WorkingDirectory = "${code_parent_dir}";
    };
  };
  
  # TODO fix this path shiz
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.services.caddy-cloud_start = {
    path = with pkgs; [
      podman
      podman-compose
    ];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    requires = ["podman.service" "podman.socket"];
    script = ''
      PATH="$PATH:${pkgs.podman}/bin";
      ${pkgs.podman-compose}/bin/podman-compose down
      # ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_caddy-cloud_podman.pid" up --no-recreate -d
      ${pkgs.podman-compose}/bin/podman-compose up  -d


      # podman-compose logs 2>&1 | while IFS= read -r line; do
      #   # Process the line
      #   if [[ "$line" == *"Listening on"* ]]; then
      #     echo "Found a match: $line"
      #     # Take action, e.g., run another command
      #     systemd-notify --ready --status="container up"
      #   else
      #     echo "x-$line"
      #   fi
      # done
      #
    '';
    unitConfig = {
      StartLimitInterval = 30;
      StartLimitBurst = 3;
      ConditionPathExists = "${code_dir}";
      RequiresMountsFor = "/run/user/1000/containers";
    };
    serviceConfig = {
      Type = "notify";
      WorkingDirectory = "${code_dir}";
      Restart = "always";
      NotifyAccess = "all";
      PIDFile = "/tmp/systemd_caddy-cloud_podman.pid"; # TODO change pid location 
      ExecStop = pkgs.writeShellScript "stop-caddy-cloud_start" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down
      '';
    };
  };
}
