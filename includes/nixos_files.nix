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

  systemd.user.services.run-home-manager = {
    description = "run-home-manager";
    after = ["nixos_files.service"];
    wantedBy = [
      "default.target"
    ];
    unitConfig = {
      ConditionPathExists = "!/home/drew/.config/home-manager";
    };
    serviceConfig = { 
      Type = "oneshot";
    };
    path = with pkgs; [
      nix
      home-manager
    ];
    script =''
      ln -s /home/drew/playin/nixos_files/home-manager /home/drew/.config/home-manager 
      whoami
      ls ~/.config
      home-manager switch --flake /home/drew/.config/home-manager
    '';
  };
}
