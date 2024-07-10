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

  # tar of the GNUPGHOME directory that is set up to decrypt the encrypted squashfs
  gpg_tar = builtins.fetchurl "file:///root/gpg_dir.tar.gz";

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
  
  link_location = "/media/${name}.img";

  encrypted_keyfile_name = "mykeyfile.key.enc";
  decrypted_keyfile_path = "/root/${name}.keyfile";

  gpgSetupCustomHome = pkgs.writeShellScriptBin "gpgSetupCustomHome" ''
    mkdir -p "$GNUPGHOME";
    chmod 700 "$GNUPGHOME";
    tar -zxvf ${gpg_tar} -C "$GNUPGHOME";
    chmod -R 700 "$GNUPGHOME";
  '';

  decrypt_keyfile_derv = pkgs.stdenv.mkDerivation {

    name = "${decrypted_device}_derivation";
    src = cloned_repo;

    buildPhase = ''
      PATH="$PATH:${gpgSetupCustomHome}/bin:${pkgs.gnupg}/bin:$PATH";

      export GNUPGHOME="./gpghome";

      gpgSetupCustomHome

      # TODO check that the signature is good; if not, explode
      gpg --yes --decrypt --output ./mykeyfile.key ./mykeyfile.key.enc;

      # want it to break if the status check failes
      status=$?;
      echo "status is $status";
      if [ 1 -eq $status ]; then
        rm ./mykeyfile.key        
      fi

      chmod 400 ./mykeyfile.key;
    '';

    # NOTE: this key needs to be held by root 
    installPhase = ''
      mkdir -p $out
      mv ${encrypted_keyfile_name} $out/ ;
      mv ./mykeyfile.key $out/ ;
    '';
  };

in {


  systemd.services."sqfs_test_decrypt_mnt_notatarget" = {
    
    description = "target to restart mount";
    
    after = [ 
      "sysinit-reactivation.target" 
    ];
    requires = [ 
      "sysinit-reactivation.target" 
    ];
    wantedBy = [
      # "multi-user.target"
      "systemd-cryptsetup@${decrypted_device}.service"
    ];

    script = ''
      link_location="${link_location}";

      # TODO we dont want to remove, if has been manually replaced :thinking: 
      rm -f "$link_location"; 

      if [ ! -e "$link_location" ];then
        ln -s "${cloned_repo}/${source_img}" "$link_location"; 
      fi
      systemctl start systemd-cryptsetup@${decrypted_device} media-${name}.mount 
    '';

    serviceConfig = {
      ExecStop =  "systemctl stop systemd-cryptsetup@${decrypted_device} media-${name}.mount";
      RemainAfterExit = "yes";
      Type = "oneshot";
    };
  };

  # https://nixos.wiki/wiki/Full_Disk_Encryption#Option_2:_Unlock_after_boot_using_crypttab_and_a_keyfile
  # first arg is the decrypted mount name
  # second arg is the path of the disk (image) 
  # must manually crate /root/mykeyfile.key, which is the decryption key
  environment.etc.crypttab.text = ''
    ${decrypted_device} ${link_location}  ${decrypt_keyfile_derv}/mykeyfile.key nofail 
  '';

  fileSystems.${mount_point} = {
    device = "/dev/mapper/${decrypted_device}";
    fsType = fsType;
    options = options; 
  };

  environment.systemPackages = [
    decrypt_keyfile_derv
    gpgSetupCustomHome
  ];
}
