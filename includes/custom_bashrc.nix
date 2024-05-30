{
  config,
  pkgs,
  ...
}: {
  systemd.services.custom_bashrc-git-repo = {
    description = "custom_bashrc-git-repo";
    wants = ["basic.target"];
    requires = ["network-online.target"];
    after = ["basic.target" "network-online.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = "!/home/drew/playin/custom_bashrc";
    };
    serviceConfig = {
      User = "drew";
      SyslogIdentifier = "custom_bashrc";
      WorkingDirectory = "/home/drew/playin";
      ExecStart = "/run/current-system/sw/bin/git clone https://github.com/yeltnar/custom_bashrc";
    };
  };

  system.activationScripts.setup_bash_profile = {
    text = ''
      date > /tmp/setup_bash_profile.log;

      text_to_add="if [ -f ~/.bashrc ]; then . ~/.bashrc; fi"
      text_to_check="# bashrc_load_done # text showing the .bashrc loading is added to profile";

      # create if not there
      if [ ! -e /home/drew/.bash_profile ]; then
        touch /home/drew/.bash_profile;
      fi

      test_str=$(cat /home/drew/.bash_profile | grep "$text_to_check");
      # echo $text_to_check;
      # echo $test_str;

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bash_profile;
        echo "$text_to_add" >> /home/drew/.bash_profile;
      fi

      echo done >> /tmp/setup_bash_profile.log;
      date >> /tmp/setup_bash_profile.log;
    '';
  };
}
