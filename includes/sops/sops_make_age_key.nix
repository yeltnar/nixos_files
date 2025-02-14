# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
{
  config,
  pkgs,
  ...
}: {
  systemd.services.sops_make_age_key = {
    path = with pkgs; [
      age 
    ];
    description = "sops_make_age_key";
    wants = ["basic.target"];
    after = ["basic.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/home/drew/.config/sops/age/keys.txt";
    };
    serviceConfig = {
      User = "drew";
      SyslogIdentifier = "sops_make_age_key";
      WorkingDirectory = "/home/drew/playin";
    };
    script = ''
      # TODO change path to use username
      mkdir -p /home/drew/.config/sops/age/
      age-keygen -o /home/drew/.config/sops/age/keys.txt
    '';
  };
}
