# THIS SHOULD NOT BE USED... USE HOME MANAGER INSTEAD
{
  config,
  pkgs,
  ...
}: let
  # TODO make the usename variable 
  sops_home_dir="/home/drew/.config/sops/age";
  # TODO make variable so it can stay in sync with sops configuration 
  sops_home_file="${sops_home_dir}/keys.txt";
  sops_etc_dir="/etc/sops/age";
  sops_etc_file="${sops_etc_dir}/keys.txt";
  shell_script = pkgs.writeShellScript "create_sops_key" ''

    if [ -e ${sops_etc_file} ]; then
      exit;
    fi

    cp ${sops_home_file} ${sops_home_file}.bk

    mkdir -p ${sops_etc_dir};
    mkdir -p ${sops_home_dir};

    # if the .config exsists, copy it to /etc, delete .config, and link .config to /etc
    # if exsists and is not a ling 
    if [ -e ${sops_home_file} ] && [ ! -L ${sops_home_file} ]; then 
      cp ${sops_home_file} ${sops_etc_file} && rm ${sops_home_file}; 
    fi 

    if [ ! -e ${sops_etc_file} ]; then
      # stderr is the private key. dont want to keep coments (so sops nix works) so remote with awk
      age-keygen 2>/dev/null | awk '!/#/' > ${sops_etc_file} ;
      age-keygen -y ${sops_etc_file} > pub.${sops_etc_file} ;
    else
      echo "${sops_etc_file} exsists... not creating new key";
    fi

    ln -s ${sops_etc_file} ${sops_home_file};
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
      ConditionPathExists = "!/etc/sops/age/keys.txt";
    };
    serviceConfig = {
      # User = "drew";
      SyslogIdentifier = "sops_make_age_key";
      # WorkingDirectory = "/home/drew/playin";
    };

    script = "${shell_script}";
    # script = ''
    #   # TODO make variable so it can stay in sync with sops configuration 
    #   mkdir -p /etc/sops/age/
    #   # stderr is the private key. dont want to keep coments (so sops nix works) so remote with awk
    #   age-keygen 2>/dev/null | awk '!/#/' > /etc/sops/age/keys.txt 
    #
    #   # TODO make the usename variable 
    #   ln -s /etc/sops/age/keys.txt ${sops_home_file}
    # '';
  };
}
