{ 
  lib, 
  pkgs, 
  repo_uri, 
  rev ? false, 
  ref ? false, 
  shallow ? true, 
  mount_point,
  options ? [],
  source_img ? "enc.img",
  fsType,
  name, 
  disable ? false,
  ... 
}: let

  fetchGitOptions = {
    url = repo_uri;
    shallow = shallow;
  } 
  # merge options 
  // (if rev != false then { rev = rev; } else {})
  // (if ref != false then { ref = ref; } else {})
  // {}
  ;

  cloned_repo = builtins.fetchGit fetchGitOptions;

  # decrypted_device = builtins.concatStringsSep "_" [
  #   "${name}"
  #   (builtins.replaceStrings [ "-" "\n" ] [ "" "" ](builtins.readFile /proc/sys/kernel/random/uuid) )
  # ];
  decrypted_device = "${name}_decrypt_mnt";

  encrypted_keyfile_name = "mykeyfile.key.enc";
  decrypted_keyfile_path = "/root/${name}.keyfile";

  xxx = pkgs.stdenv.mkDerivation {

    name = "${decrypted_device}_derivation";
    src = cloned_repo;

    buildPhase = ''
      echo whoami; 
    '';

    # NOTE: this key needs to be held by root 
    installPhase = ''
      mkdir -p $out
      mv ${encrypted_keyfile_name} $out/ ;
    '';
  };

in {

  system.activationScripts.config_img_setup = {
    text = ''
      export PATH="$PATH:${pkgs.gnupg}/bin";
      gpg --yes --decrypt --output ${decrypted_keyfile_path} ${xxx}/${encrypted_keyfile_name};
      # make sure the decryption goes well 
      if [ $? -eq 0 ]; then
        chmod 400 ${decrypted_keyfile_path};
      else
        rm ${decrypted_keyfile_path};
      fi
    '';
  };

  system.activationScripts.config_img_deactivation = {
    text = ''      
      export PATH="$PATH:${pkgs.systemd}/bin";

      # TODO make this conditional, if the service exsists
      systemctl stop systemd-cryptsetup@${decrypted_device}.service 
    '';
  };

  systemd.services."sqfs_test_decrypt_mnt_notatarget" = {
    
    description = "target to restart mount";
    
    after = [ 
      "sysinit-reactivation.target" 
    ];
    requires = [ 
      "sysinit-reactivation.target" 
    ];
    wantedBy = [
      "multi-user.target"
      # "systemd-cryptsetup@${decrypted_device}.service"
      # "media-${decrypted_device}.mount"
    ];

    serviceConfig = {
      ExecStart = "systemctl start systemd-cryptsetup@${decrypted_device} media-${name}.mount";
      # ExecStop =  "systemctl stop systemd-cryptsetup@${decrypted_device} media-${name}.mount";
    };
  };

  # https://nixos.wiki/wiki/Full_Disk_Encryption#Option_2:_Unlock_after_boot_using_crypttab_and_a_keyfile
  # first arg is the decrypted mount name
  # second arg is the path of the disk (image) 
  # must manually crate /root/mykeyfile.key, which is the decryption key
  environment.etc.crypttab.text = ''
    ${decrypted_device} ${cloned_repo}/${source_img} ${decrypted_keyfile_path} nofail 
  '';

  fileSystems.${mount_point} = {
    device = "/dev/mapper/${decrypted_device}";
    fsType = fsType;
    options = options; 
  };

  environment.systemPackages = [
    xxx
  ];
}
