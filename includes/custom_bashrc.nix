{
  config,
  pkgs,
  ...
}: {
  systemd.services.custom_bashrc-git-repo = {
    description = "custom_bashrc-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/home/drew/playin/custom_bahsrc";
    };
    serviceConfig = {
      User = "drew";
      SyslogIdentifier = "custom_bahsrc";
      WorkingDirectory = "/home/drew/playin";
      ExecStart = "/run/current-system/sw/bin/git clone https://github.com/yeltnar/custom_bashrc";
    };
  };
}
