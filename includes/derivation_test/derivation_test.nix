{ lib, pkgs, repo_uri, name, ... }: let
  cloned_repo = builtins.fetchGit {
    url = repo_uri;
  };
  prog_to_add = pkgs.stdenv.mkDerivation {
    name = name;
    # src = cloned_repo;
    src = "/tmp";

    buildPhase = ''
      whoami;
      file=${name};
      echo "echo `date`" > $file;
      echo "date" >> $file;
      echo "echo ${cloned_repo}" >> $file;
      echo "echo ${repo_uri}" >> $file;
    '';

    installPhase = ''
      mkdir -p $out/bin;
      file=${name};
      chmod u+x $file;
      cp $file $out/bin/;
    '';
  };
in {
  environment.systemPackages = [ prog_to_add ];
}
