# A Nix expression that evaluates to a function taking an attribute set of environment variables.
{ pkgs, REPO ? "", BASE_HOSTNAME ? "", USERNAME ? "", REPO_NAME ? "", USE_WORKTREE ? "default", ... }:

let
  # pkgs = import <nixpkgs> { };
  create_script = pkgs.writeShellScript "git-clone" ''
    set -euo pipefail

    if [ -z "''${REPO:-}" ]; then
      BASE_HOSTNAME="''${BASE_HOSTNAME:-git@github.com:}"
      USERNAME="''${USERNAME:-yeltnar}"
      REPO_NAME="''${REPO_NAME:-nixos_files}"
      REPO="$BASE_HOSTNAME$USERNAME/$REPO_NAME"
    elif [ -z "''${REPO_NAME:-}" ]; then
      REPO_NAME="''${REPO##*/}"
      REPO_NAME="''${REPO_NAME%.git}"
    fi

    BARE_DIR="$HOME/playin/worktree_$REPO_NAME"
    WORKTREE_DIR="$HOME/playin/$REPO_NAME"

    mkdir -p "$HOME/playin"

    if [ -z "''${USE_WORKTREE:-}" ]; then
      if [ ! -d "$WORKTREE_DIR" ]; then
        git clone "$REPO" "$WORKTREE_DIR"
      fi
    else
      if [ ! -d "$BARE_DIR" ]; then
        git clone --bare "$REPO" "$BARE_DIR"
      fi

      if [ ! -d "$WORKTREE_DIR" ]; then
        git --git-dir="$BARE_DIR" worktree add "$WORKTREE_DIR" main
      fi
    fi
  '';
in
pkgs.writeShellScriptBin "env-git-clone" ''
  export REPO="${toString REPO}"
  export BASE_HOSTNAME="${toString BASE_HOSTNAME}"
  export USERNAME="${toString USERNAME}"
  export REPO_NAME="${toString REPO_NAME}"
  export USE_WORKTREE="${toString USE_WORKTREE}"

  exec ${create_script}
''
