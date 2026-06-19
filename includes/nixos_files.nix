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
    serviceConfig = { 
      Type = "oneshot";
    };
    path = with pkgs; [
      git
    ];
    script = ''
      set -euo pipefail

      REPO="git@github.com:yeltnar/nixos_files"
      NAME="nixos_files"

      BARE_DIR="$HOME/playin/worktree_$NAME"
      WORKTREE_DIR="$HOME/playin/$NAME"

      mkdir -p "$HOME/playin"

      if [ ! -d "$BARE_DIR" ]; then
        git clone --bare "$REPO" "$BARE_DIR"
      fi

      if [ ! -d "$WORKTREE_DIR" ]; then
        git --git-dir="$BARE_DIR" worktree add "$WORKTREE_DIR" main
      fi
    '';
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
