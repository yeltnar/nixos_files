# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: let
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/jellyfin";  
  run_env_file = "/home/drew/.config/jellyfin/changeme.env";
  backup_env_file = "/home/drew/.config/jellyfin/backup.env";
in {
  networking.firewall.allowedTCPPorts = [
    8096
  ];

  # TODO move to jellyfin file
  sops.secrets."jellyfin.env" = {
    owner = "drew";
    path = run_env_file;
    sopsFile = ./secrets.yaml;
  };
  
  # enable lingering so service starts before user logs in
  users.users.drew.linger = true;

  systemd.user.services.jellyfin-git-repo = {
    path = with pkgs; [
      git
    ];
    description = "jellyfin-git-repo";
    # requires = ["network-online.target"];
    # after = ["default.target" "network-online.target"];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    unitConfig = {
      ConditionPathExists = "!${code_dir}";
    };
    script = ''
      cd ${code_parent_dir}/; git clone https://github.com/yeltnar/jellyfin;
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "jellyfin";
      WorkingDirectory = "${code_parent_dir}";
    };
    onSuccess = [
      "restore.jellyfin.service"
    ];
  };
  
  # TODO fix this path shiz
  # systemd.user.extraConfig = ''
  #   DefaultEnvironment="PATH=/run/current-system/sw/bin"
  # '';

  systemd.user.services.jellyfin_start = {
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
      # ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/jellyfin.podman.pid" up --no-recreate -d
      # ${pkgs.podman-compose}/bin/podman-compose up  -d
      ${pkgs.podman-compose}/bin/podman-compose --env-file ${run_env_file} --verbose up --build -d |& tee log.txt
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
      PIDFile = "/tmp/jellyfin.podman.pid"; # TODO change pid location 
      ExecStop = pkgs.writeShellScript "stop-jellyfin" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down
      '';
    };
  };
}
