{ 
  lib, 
  pkgs, 
  repo_uri, 
  rev ? false, 
  ref ? false, 
  shallow ? true, 
  mount_point,
  options ? [],
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

  disk_img_derivation = pkgs.stdenv.mkDerivation {
    name = name;
    src = cloned_repo;

    buildPhase = ''
      whoami;
    '';

    installPhase = ''
      mkdir -p $out/bin;
      cp disk.img $out/${name}.img;
    '';
  };

in {

  fileSystems.${mount_point} = {
    device = "${disk_img_derivation}/${name}.img";
    fsType = fsType;
    options = options; 
  };
}
