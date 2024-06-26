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

  # decrypted_device = builtins.replaceStrings [ "-" "\n" ] [ "" "" ](builtins.readFile /proc/sys/kernel/random/uuid); 
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
      mv ${encrypted_keyfile_name} $out/ ;
    '';
  };

in {

  system.activationScripts.config_img_activationn = {
    text = ''
      export PATH="$PATH:${pkgs.gnupg}/bin";
      gpg --yes --decrypt --output ${decrypted_keyfile_path} ${xxx}/${encrypted_keyfile_name}
      chmod 400 ${decrypted_keyfile_path};
    '';
  };

  # https://nixos.wiki/wiki/Full_Disk_Encryption#Option_2:_Unlock_after_boot_using_crypttab_and_a_keyfile
  # first arg is the decrypted mount name
  # second arg is the path of the disk (image) 
  # must manually crate /root/mykeyfile.key, which is the decryption key
  environment.etc.crypttab.text = ''
    ${decrypted_device} ${cloned_repo}/${source_img} ${decrypted_keyfile_path} 
  '';

  fileSystems.${mount_point} = {
    device = "/dev/mapper/${decrypted_device}";
    fsType = fsType;
    options = options; 
  };
}
