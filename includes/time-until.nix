{
  config,
  pkgs,
  ...
}: {
  systemd.services.git_clone_test = {
    description = "git_clone_test";
    wants = ["basic.target"];
    after = ["basic.target" "network.target"];
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
