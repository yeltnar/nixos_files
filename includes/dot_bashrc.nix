{
  system.activationScripts.setup_bash_profile = {
    text = ''
      text_to_add='bashrc_folder="/home/drew/playin/custom_bashrc";\n. /home/drew/playin/custom_bashrc/entrypoint.sh;';
      text_to_check='# bashrc_load_done';

      # create if not there
      if [ ! -e /home/drew/.bashrc ]; then
        touch /home/drew/.bashrc;
       chown 1000:100 /home/drew/.bashrc || echo "error with custom_bashrc" ; exit ;# TODO fix this, it is kinda hard coded
      fi

      test_str=$(cat /home/drew/.bashrc | grep "$text_to_check");
      # echo $text_to_check;
      # echo $test_str;

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bashrc;
        echo -e "$text_to_add" >> /home/drew/.bashrc;
      fi
    '';
  };
}
