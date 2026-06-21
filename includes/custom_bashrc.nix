# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
args@{
  config,
  pkgs,
  ...
}: let
  bareCloneWorktree = import ./bare-clone-worktree.nix;
in {
  imports = [ ./nm-online.service.nix ];

  systemd.user.services.custom_bashrc-git-repo = {
    description = "custom_bashrc-git-repo";
    wants = ["basic.target"];
    after = ["basic.target" "network-online.target" "nm-online.service"];
    wantedBy = [
      "default.target"
    ];
    unitConfig = {
      ConditionPathExists = "!/home/drew/playin/custom_bashrc";
    };
    serviceConfig = {
      SyslogIdentifier = "custom_bashrc";
    };
    path = with pkgs; [
      git
    ];
    script =''
      ${bareCloneWorktree (args // {
        REPO_NAME = "custom_bashrc";
        USE_WORKTREE = "true";
      })}/bin/env-git-clone

      PATH="$PATH:${pkgs.git}/bin:${pkgs.curl}/bin"
      /home/drew/playin/custom_bashrc/setup.sh

      # Define the target file
      TARGET="$HOME/.bash_profile"
      
      # Check if the file exists
      if [ ! -f "$TARGET" ]; then
          echo "# include .profile if it exists" > "$TARGET"
          echo "[[ -f ~/.profile ]] && . ~/.profile" >> "$TARGET"
          echo "" >> "$TARGET"
          echo "# include .bashrc if it exists" >> "$TARGET"
          echo "[[ -f ~/.bashrc ]] && . ~/.bashrc" >> "$TARGET"
      fi

    '';
  };

  # system.activationScripts.setup_bash_profile = {
  #   text = ''
  #     date > /tmp/setup_bash_profile.log;
  #
  #     text_to_add="if [ -f ~/.bashrc ]; then . ~/.bashrc; fi"
  #     text_to_check="# bashrc_load_done # text showing the .bashrc loading is added to profile";
  #
  #     # create if not there
  #     if [ ! -e /home/drew/.bash_profile ]; then
  #       touch /home/drew/.bash_profile;
  #     fi
  #
  #     test_str=$(cat /home/drew/.bash_profile | grep "$text_to_check");
  #     # echo $text_to_check;
  #     # echo $test_str;
  #
  #     if [ -z "$test_str" ]; then
  #       echo "$text_to_check" >> /home/drew/.bash_profile;
  #       echo "$text_to_add" >> /home/drew/.bash_profile;
  #     fi
  #
  #     echo done >> /tmp/setup_bash_profile.log;
  #     date >> /tmp/setup_bash_profile.log;
  #   '';
  # };
}
