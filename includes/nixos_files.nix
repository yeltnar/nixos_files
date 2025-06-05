# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
{
  config,
  pkgs,
  ...
}: {
  imports = [ ./nm-online.service.nix ];

  systemd.user.services.nixos_files-git-repo = {
    description = "nixos_files-git-repo";
    after = ["nm-online.service"];
    wants = ["basic.target"];
    wantedBy = [
      "default.target"
    ];
    unitConfig = {
      ConditionPathExists = "!/home/drew/playin/nixos_files";
    };
    script =''
      mkdir -p /home/drew/playin
      cd /home/drew/playin
      ${pkgs.git}/bin/git clone https://github.com/yeltnar/nixos_files
    '';
  };
}
