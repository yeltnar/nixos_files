# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{
  config,
  pkgs,
  ...
}: {
  # for
  #   nebula-ansible = builtins.fetchGit {
  #     url = "https://github.com/yeltnar/nebula-ansible";
  #   }
  # in

  system.activationScripts.setup_nebula_env = {
    text = ''

      text_to_check='# setup nebula env # ';
      text_to_add="
        # create if not there
        if [ ! -e /var/yeltnar-nebula/.env ]; then
          # TODO add prompt to ask if you want to
          echo \"create /var/yeltnar-nebula/.env? y/n\";
          read do_edit;
          if [ \"\$do_edit\" == \"y\" ]; then
            vim /var/yeltnar-nebula/.env;
          fi
        fi
       ";

      # create bashrc if not there
      if [ ! -e /home/drew/.bashrc ]; then
        # TODO add prompt to ask if you want to
        touch /home/drew/.bashrc;
        chown drew /home/drew/.bashrc;
      fi

      test_str=$(cat /home/drew/.bashrc | grep "$text_to_check");
      # echo $text_to_check;
      # echo $test_str;

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bashrc;
        echo "$text_to_add" >> /home/drew/.bashrc;
      fi
    '';
  };
}
