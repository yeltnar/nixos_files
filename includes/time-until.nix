{
  config,
  pkgs,
  ...
}: {
  systemd.services.time-until-git-repo = {
    description = "time-until-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/tmp/time-until";
    };
    serviceConfig = {
      User = "drew";
      SyslogIdentifier = "time-until";
      WorkingDirectory = "/tmp";
      ExecStart = "/run/current-system/sw/bin/git clone https://github.com/yeltnar/time-until";
    };
  };
}
