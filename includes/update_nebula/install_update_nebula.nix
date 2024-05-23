{
  config,
  pkgs,
  ...
}: let
  cloned_repo = builtins.fetchGit {
    url = "https://github.com/yeltnar/nebula-ansible";
  };
in {
  system.activationScripts.setup_nebula_env = {
    text = ''


      text_to_check="# setup nebula env # ";

      dir_to_add="/home/drew/.config/extra_includes";
      file_to_add="$dir_to_add/setup_nebula_env";
      text_to_add="source $file_to_add"; # TODO remove

      read -r -d \'\' text_to_add << EOM
        if [[ \$- == *i* ]]
        then
            source $file_to_add
        fi
      EOM
      # I dont know why the indentation is odd

      mkdir -p "$dir_to_add";
      chown -R drew:100 "$dir_to_add";

      # create source'd file if not there
      cat > $file_to_add <<- EOM
        # DO NOT EDIT THIS FILE... IT IS GENERATED

        # only continue if interactive
        if [[ ! \$- == *i* ]]
        then
            exit;
        fi


        # alert missing files
        if [ ! -e /var/yeltnar-nebula/.env ]; then
          echo "!! /var/yeltnar-nebula/.env is not present";
        fi
        if [ ! -e /var/yeltnar-nebula/knownca.pem ]; then
          echo "!! /var/yeltnar-nebula/knownca.pem is not present";
        fi
        if [ ! -e /var/yeltnar-nebula/id_rsa ]; then
          echo "!! /var/yeltnar-nebula/id_rsa is not present";
        fi
        if [ ! -e /var/yeltnar-nebula/id_rsa.pub ]; then
          echo "!! /var/yeltnar-nebula/id_rsa.pub is not present";
        fi
      EOM

      chown drew:100 "$file_to_add";

      # create bashrc file if not there
      if [ ! -e /home/drew/.bashrc ]; then
        touch /home/drew/.bashrc;
        chown drew /home/drew/.bashrc;
      fi

      # create update_nebula dir if not there
      if [ ! -d /var/yeltnar-nebula ]; then
        mkdir -p /var/yeltnar-nebula
        chown drew /var/yeltnar-nebula;
      fi

      # create compare_date.sh file if not there
      if [ ! -e /var/yeltnar-nebula/compare_date.sh ]; then
        cp ${cloned_repo.outPath}/compare_date.sh /var/yeltnar-nebula/compare_date.sh;
        chown drew:100 /var/yeltnar-nebula/compare_date.sh;
      fi
      # create process_tar.sh file if not there
      if [ ! -e /var/yeltnar-nebula/process_tar.sh ]; then
        cp ${cloned_repo.outPath}/process_tar.sh /var/yeltnar-nebula/process_tar.sh;
        chown drew:100 /var/yeltnar-nebula/process_tar.sh;
      fi

      # TODO # create id_rsa(.pub) if they're not there;
      if [ ! -e /var/yeltnar-nebula/id_rsa ]; then
        pushd /var/yeltnar-nebula;
        # TODO # create id_rsa(.pub) if they're not there;
        ${pkgs.openssh}/bin/ssh-keygen -t rsa -m PEM -N "" -q -f "/var/yeltnar-nebula/id_rsa" -b 4096;
        popd;
      fi

      test_str=$(cat /home/drew/.bashrc | grep "$text_to_check");
      # echo $text_to_check;
      # echo $test_str;

      if [ -z "$test_str" ]; then
        echo "$text_to_check" >> /home/drew/.bashrc;
        echo "$text_to_add" >> /home/drew/.bashrc;
      fi

      exit;
    '';
  };
}
