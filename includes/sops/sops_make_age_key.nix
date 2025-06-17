# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
{
  config,
  pkgs,
  ...
}: let
  user="drew";
  group="users";
  config_dir="/home/${user}/.config";
  sops_home_dir="${config_dir}/sops/age";
  # TODO make variable so it can stay in sync with sops configuration 
  sops_home_file="${sops_home_dir}/keys.txt";
  sops_etc_dir="/etc/sops/age";
  sops_etc_file="${sops_etc_dir}/keys.txt";
  shell_script = pkgs.writeShellScript "create_sops_key" ''

    mkdir -p ${sops_etc_dir};
    mkdir -p ${sops_home_dir};
    chown -R ${user}:${group} ${config_dir}

    if [ ! -e ${sops_home_file} ]; then
      ln -s ${sops_etc_file} ${sops_home_file};
    else
      echo "${sops_home_file} exsists... not creating link";
    fi

    # check if the etc file exsists!
    if [ ! -e ${sops_etc_file} ]; then

      # if the .config exsists and is not a link, copy it to /etc and replace the file with link to etc
      # otherwise, generate a new key 
      # note: this is in a block where the etc version is know not to exsist 
      if [ -e ${sops_home_file} ] && [ ! -L ${sops_home_file} ]; then 
        cp -a ${sops_home_file} ${sops_home_file}.bk
        cp ${sops_home_file} ${sops_etc_file} && rm ${sops_home_file}; 
        ln -s ${sops_etc_file} ${sops_home_file};
      else
        # stderr is the private key. dont want to keep coments (so sops nix works) so remove with awk
        age-keygen 2>/dev/null | awk '!/#/' > ${sops_etc_file} ;
        age-keygen -y ${sops_etc_file} > pub.${sops_etc_file} ;
      fi 

    else
      echo "${sops_etc_file} exsists... not creating new key";
    fi

  '';
in {
  systemd.services.sops_make_age_key = {
    path = with pkgs; [
      age 
      gawk
    ];
    description = "sops_make_age_key";
    wants = ["basic.target"];
    after = ["basic.target"];
    wantedBy = ["multi-user.target"];
    unitConfig = {
      ConditionPathExists = [
        # add pipe symbol to result in OR logic
        "|!/etc/sops/age/keys.txt"
        "|!/home/${user}/.config/sops/age/keys.txt"
      ];
    };
    serviceConfig = {
      # User = "${user}";
      SyslogIdentifier = "sops_make_age_key";
      # WorkingDirectory = "/home/${user}/playin";
    };

    script = "${shell_script}";
  };
}
