# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
{
  config,
  pkgs,
  ...
}: {
  systemd.services.sops_make_age_key = {
    path = with pkgs; [
      age 
      gawk
    ];
    description = "sops_make_age_key";
    wants = ["basic.target"];
    after = ["basic.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/etc/sops/age/keys.txt";
    };
    serviceConfig = {
      # User = "drew";
      SyslogIdentifier = "sops_make_age_key";
      # WorkingDirectory = "/home/drew/playin";
    };
    script = ''
      # TODO change path to use username
      mkdir -p /etc/sops/age/
      # stderr is the private key. dont want to keep coments (so sops nix works) so remote with awk
      age-keygen 2>/dev/null | awk '!/#/' > /etc/sops/age/keys.txt 
    '';
  };
}
