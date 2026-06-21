# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
args@{
  config,
  pkgs,
  ...
}: let 
  bareCloneWorktree = import ./bare-clone-worktree.nix;
in {
  imports = [ 
    ./nm-online.service.nix 
  ];


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
    serviceConfig = { 
      Type = "oneshot";
    };
    path = with pkgs; [
      git
    ];
    script = "${bareCloneWorktree args // {
      REPO_NAME = "nixos_files";
      USE_WORKTREE = "true";
    }}/bin/env-git-clone";
  };

  systemd.user.services.run-home-manager = {
    description = "run-home-manager";
    after = ["nixos_files-git-repo.service"];
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
      mkdir -p /home/drew/.config
      ln -s /home/drew/playin/nixos_files/home-manager /home/drew/.config/home-manager 
      whoami
      ls ~/.config
      home-manager switch --flake /home/drew/.config/home-manager
    '';
  };
}
