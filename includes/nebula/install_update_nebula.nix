# this will set up the network updating functionality 
# to create the cert, etc for this device, copy the id_rsa.pub to the machine that will generate the new files
# this will also generate a .default.env file wich can be overwritten with the .env file in the same directory 
# the rest _should_ be taken care of with the script and systemd timer 
{
  config,
  pkgs,
  user,
  group ? "100",
  SECONDARY_HOST ? "hot.h.lan",
  HOST ? "10.10.10.8",
  PORT ? "2323",
  CURL_OPTIONS ? "--cacert ./knownca.pem",
  SECONDARY_PORT ? "443",
  SECONDARY_CURL_OPTIONS ? "--cacert ./knownca.pem",
  DEVICE_NAME ? "${config.networking.hostName}" ,
  DATE_FILE_PATH ? "/var/yeltnar-nebula/tar_stuff/remote_updated.date",
  var_dir ? "/var/yeltnar-nebula",
  nebula_config_client_folder ? "/etc/nebula",
  cacert ? ''
  -----BEGIN CERTIFICATE-----
  MIIBozCCAUqgAwIBAgIRAPZn1/oD/c0M9GhKndrWbmcwCgYIKoZIzj0EAwIwMDEu
  MCwGA1UEAxMlQ2FkZHkgTG9jYWwgQXV0aG9yaXR5IC0gMjAyMSBFQ0MgUm9vdDAe
  Fw0yMTEwMDMwNDIzNDdaFw0zMTA4MTIwNDIzNDdaMDAxLjAsBgNVBAMTJUNhZGR5
  IExvY2FsIEF1dGhvcml0eSAtIDIwMjEgRUNDIFJvb3QwWTATBgcqhkjOPQIBBggq
  hkjOPQMBBwNCAAR4V9bn+bmOJfWlIGkNZyy+FzHCxIZiU3Ko6f+MgY9fbZddVvZU
  +qUMqdj1jOOSHGb2oksfABkhrJAnNcqtafH9o0UwQzAOBgNVHQ8BAf8EBAMCAQYw
  EgYDVR0TAQH/BAgwBgEB/wIBATAdBgNVHQ4EFgQUGxw7vsSlsHoIbX3fqTwnH8+8
  Ni0wCgYIKoZIzj0EAwIDRwAwRAIgAPmMzq8t6N9H6wUyxEjYZY870ysKNxtrBrmK
  JmH3busCICZnli09FnPU9/3mt6Kf1AhEF6X3evM+J/P1gEGOqM9u
  -----END CERTIFICATE-----
  '',
  ...
}: let
  cloned_repo = builtins.fetchGit {
    url = "https://github.com/yeltnar/nebula-ansible";
    rev = "5f674ec95c8656f10d86cdc7913b82af0256ec13";
  };
  vardir = "/var/yeltnar-nebula";
in {

  imports = [
    # these scripts depend on some custom scripts, so need this setup
    ../../includes/custom_bashrc.nix
  ];

  systemd.services.setup_nebula_env = {

    after = ["sysinit-reactivation.target"];
    wantedBy = ["basic.target"];
    partOf = ["sysinit-reactivation.target"]; 
    script = /*bash*/ ''

      # create update_nebula dir if not there
      if [ ! -d ${vardir} ]; then
        mkdir -p ${vardir}
        chown ${user} ${vardir};
      fi

      # set up the cert for the private network for the update script 
      cat <<EOCERT > ${vardir}/knownca.pem
      ${cacert}
      EOCERT
      
      # set defaults which can be overwritten with the .env file 
      cat <<EOENV > ${vardir}/.default.env
      # GENERATED; DO NOT EDIT; use .env if you need to edit
      export HOST="${HOST}";
      export PORT="${PORT}";
      export CURL_OPTIONS="${CURL_OPTIONS}";
      
      export SECONDARY_PORT="${SECONDARY_PORT}";
      export SECONDARY_HOST="${SECONDARY_HOST}";
      export SECONDARY_CURL_OPTIONS="${SECONDARY_CURL_OPTIONS}";
      
      # Make sure this device name matches the one on the server  
      export DEVICE_NAME="${DEVICE_NAME}" 
      export DATE_FILE_PATH="${DATE_FILE_PATH}";
      export var_dir="${var_dir}";
      export nebula_config_client_folder="${nebula_config_client_folder}";
      EOENV

      # create compare_date.sh file if not there
      if [ ! -e ${vardir}/compare_date.sh ]; then
        cp ${cloned_repo.outPath}/compare_date.sh ${vardir}/compare_date.sh;
        chown ${user}:${group} ${vardir}/compare_date.sh;
      fi

      # create process_tar.sh file if not there
      if [ ! -e ${vardir}/process_tar.sh ]; then
        cp ${cloned_repo.outPath}/process_tar.sh ${vardir}/process_tar.sh;
        chown ${user}:${group} ${vardir}/process_tar.sh;
      fi

      # # this is replaced by sops
      # # generate id_rsa keypair if it is not there 
      # if [ ! -e ${vardir}/id_rsa ]; then
      #   pushd ${vardir};
      #   ${pkgs.openssh}/bin/ssh-keygen -t rsa -m PEM -N "" -q -f "${vardir}/id_rsa" -b 4096;
      #   popd;
      # fi

      systemctl restart nebula.service
    '';
    serviceConfig = {
      Type = "oneshot"; 
      WorkingDirectory = "/home/${user}";
      ExecStartPre = pkgs.writeScript "check-dir-exists" ''
        #!${pkgs.bash}/bin/bash
        dir="/home/drew/playin/custom_bashrc/"
        while [ ! -d "$dir" ]; do
          echo "Waiting for $dir"
          sleep 10
        done
      '';
    };
  };
  sops.secrets."yeltnar_nebula_id_rsa" = {
    path = "/var/yeltnar-nebula/id_rsa";
  };
}
