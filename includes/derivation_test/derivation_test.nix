{ lib, pkgs, repo_uri, ... }: let
  cloned_repo = builtins.fetchGit {
    url = repo_uri;
  };
  xxx = pkgs.stdenv.mkDerivation {
    name = "derivation_test";
    # src = cloned_repo;
    src = "/tmp";

    buildPhase = ''
      whoami;
      echo "echo `date`" > date_derivation;
      echo "date" >> date_derivation;
      echo "echo ${cloned_repo}" >> date_derivation;
      echo "echo ${repo_uri}" >> date_derivation;
    '';

    installPhase = ''
      mkdir -p $out/bin;
      chmod u+x date_derivation;
      cp date_derivation $out/bin/;
    '';
  };
in {
  environment.systemPackages = [xxx];
}
