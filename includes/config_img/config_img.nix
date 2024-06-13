{ lib, pkgs, repo_uri, rev ? false, name, ... }: let

  fetchGitOptions = if rev
    then  {
      url = repo_uri;
      rev = rev;
      shallow = true;
    }
    else {
      url = repo_uri;
      shallow = true;
    };


  cloned_repo = builtins.fetchGit fetchGitOptions;
  old_prog_to_add = pkgs.stdenv.mkDerivation {
    name = name;
    src = cloned_repo;
    # src = "/tmp";

    buildPhase = ''
      whoami;
      file=${name};
      echo "echo `date`" > $file;
      echo "date" >> $file;
      echo "echo cloned_repo ${cloned_repo}" >> $file;
      echo "echo repo_uri ${repo_uri}" >> $file;
      echo "echo out $out" >> $file;
      echo "echo src $src" >> $file;
    '';

    installPhase = ''
      mkdir -p $out/bin;
      file=${name};
      chmod u+x $file;
      cp $file $out/bin/;
      cp disk.img $out/${name}.img;
    '';
  };

  prog_to_add = pkgs.stdenv.mkDerivation {
    name = name;
    # src = cloned_repo;
    src = "/tmp";

    buildPhase = ''
      whoami;
      file=${name}_new;
      echo "echo `date`" > $file;
      echo "date" >> $file;
      echo "echo cloned_repo ${cloned_repo}" >> $file;
      echo "echo repo_uri ${repo_uri}" >> $file;
      echo "echo out $out" >> $file;
      echo "echo src $src" >> $file;
      echo "echo ${old_prog_to_add}/bin/* $out/bin/" >> $file
    '';

    installPhase = ''
      file=${name}_new;
      mkdir -p $out/bin;
      cp -ar ${old_prog_to_add}/bin/* $out/bin/;
      chmod u+x $file;
      cp $file $out/bin/;
    '';
  };
in {
  environment.systemPackages = [ 
    prog_to_add 
  ];

  fileSystems."/media/btrfs_test" = {
    device = "${old_prog_to_add}/${name}.img";
    fsType = "btrfs";
    options = [
      "nofail"
      "compress=zstd"
      "subvol=root"
    ];
  };
}
