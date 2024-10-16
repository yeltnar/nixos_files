{
  config,
  pkgs,
  ...
}: {
  systemd.services.make_playin = {
    description = "make_playin";
    wants = ["basic.target"];
    after = ["basic.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/home/drew/playin";
    };
    serviceConfig = {
      User = "drew";
      SyslogIdentifier = "make_playin";
      WorkingDirectory = "/home/drew/";
      ExecStart = "/run/current-system/sw/bin/mkdir /home/drew/playin";
    };
  };
}
