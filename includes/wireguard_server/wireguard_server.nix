# man systemd-socket-proxyd
{
  # config,
  pkgs,
  ...
}: let
  name="wireguard_server";
  code_parent_dir="/home/drew/playin";
  code_dir="${code_parent_dir}/${name}";  
in {
  networking.firewall.allowedUDPPorts = [
    51820
  ];

  imports = [ ../nm-online.service.nix ];

  # enable lingering so service starts before user logs in
  users.users.drew.linger = true;

  systemd.user.services."${name}-git-repo" = {
    path = with pkgs; [
      git
    ];
    description = "${name}-git-repo";
    after = ["nm-online.service"];
    wantedBy = [
      "default.target"
      "multi-user.target"
    ];
    unitConfig = {
      ConditionPathExists = "!${code_dir}";
    };
    script = ''
      mkdir -p ${code_parent_dir}/; 
      cd ${code_parent_dir}/; git clone https://github.com/yeltnar/${name};
    '';
    serviceConfig = {
      Type = "oneshot";
      SyslogIdentifier = "${name}";
    };
    onSuccess = [
      "restore.${name}.service"
    ];
  };
  
  # TODO fix this path shiz
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/current-system/sw/bin"
  '';

  systemd.user.services."${name}-start" = {
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
      ${pkgs.podman-compose}/bin/podman-compose up  -d

      str="All tunnels are now active";

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
