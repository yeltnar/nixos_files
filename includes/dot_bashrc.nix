{
  system.activationScripts.setup_bash_profile_second = {
    text = ''
      # date > /tmp/setup_bash_profile_second;

      text_to_check="# bashrc_load_done";

      read -r -d \'\' text_to_add << EOM
        if [[ \$- == *i* ]]; then
          bashrc_folder="/home/drew/playin/custom_bashrc";
          . /home/drew/playin/custom_bashrc/entrypoint.sh;
        fi
      EOM
      # I dont know why the indentation is odd

      # create if not there
      if [ ! -e /home/drew/.bashrc ]; then
        touch /home/drew/.bashrc;
        chown -v 1000:100 /home/drew/.bashrc # TODO fix this, it is kinda hard coded
      fi

      test_str=$(cat /home/drew/.bashrc | grep "$text_to_check");

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bashrc;
        echo "$text_to_add" >> /home/drew/.bashrc;
      fi
    '';
  };
}
