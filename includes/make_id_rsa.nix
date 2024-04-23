{
  config,
  pkgs,
  ...
}: {
  systemd.services.create_ssh_keypair = {
    path = with pkgs; [
      openssh
    ];
    description = "create_ssh_keypair";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/home/drew/.ssh/id_generated";
    };
    script = ''
      ssh-keygen -t ed25519 -N "" -q -f /home/drew/.ssh/id_generated
      chmod 600 ~/.ssh/id_generated
      chmod 600 ~/.ssh/id_generated.pub
    '';
    serviceConfig = {
      User = "drew";
      Type = "oneshot";
      SyslogIdentifier = "create_ssh_keypair";
      WorkingDirectory = "/tmp";
    };
  };
}
