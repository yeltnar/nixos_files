# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: let
  name="babybuddy";
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/${name}";  
in {
  imports = [ ../nm-online.service.nix ];

  networking.firewall.allowedTCPPorts = [
    # port for container
    8000
  ];

  sops.secrets."babybuddy_backup.env" = {
    owner = "drew";
    sopsFile = ./secrets.yaml;
    path = "/home/drew/.config/babybuddy/backup.env";
  };

  # enable lingering so service starts before user logs in
  users.users.drew.linger = true;

  # need to run as system service (not user) because this starts the restore service which must be root 
  systemd.services."${name}-git-repo" = {
    path = with pkgs; [
      git
    ];
    description = "${name}-git-repo";
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    after = ["default.target" "nm-online.service"];
    unitConfig = {
      ConditionPathExists = "!${code_dir}";
    };
    script = ''
      ${pkgs.util-linux}/bin/runuser -u drew -- ${pkgs.bash}/bin/bash -c 'mkdir -p ${code_parent_dir}; cd ${code_parent_dir}/; git clone https://github.com/yeltnar/${name}';
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "${name}";
    };
    onSuccess = [
      "restore.babybuddy.service"
    ];
  };
  
  # TODO fix this path shiz
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.user.services."${name}_start" = {
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
      # ${pkgs.podman-compose}/bin/podman-compose --podman-run-args="--replace --sdnotify=container --pidfile=/tmp/systemd_${name}_podman.pid --gpus=all" up --no-recreate -d
      ${pkgs.podman-compose}/bin/podman-compose up  -d

      str="Listening on";

      testit(){
        podman-compose logs | grep "$str" >& /dev/null
        echo $?
      }

      while [ 1 -eq `testit` ] ;
      do 
        echo loop again
        sleep 1
      done

      systemd-notify --ready --status="container up"

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
      PIDFile = "/tmp/systemd_${name}_podman.pid"; # TODO change pid location 
      ExecStop = pkgs.writeShellScript "stop-${name}_start" ''
        PATH="$PATH:${pkgs.podman}/bin";
        ${pkgs.podman-compose}/bin/podman-compose down
      '';
    };
  };
}
