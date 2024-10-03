{ pkgs, ... }: let
  xxx = pkgs.stdenv.mkDerivation {
    name = "nbdkit";

    buildInputs = [
      pkgs.libgcc 
      pkgs.gnumake 
      pkgs.perl
      pkgs.autoconf
      pkgs.automake
      pkgs.bash

      # TODO remove 
      pkgs.tree
    ];

    #src = builtins.fetchGit {
    #  url = "https://gitlab.com/nbdkit/nbdkit.git";
    #  ref = "v1.40.3";
    #  shallow = true;
    #};

    src = builtins.fetchTarball {
      url = "https://download.libguestfs.org/nbdkit/1.40-stable/nbdkit-1.40.4.tar.gz";
    #  ref = "v1.40.3";
    #  shallow = true;
    };

    # phases = [ "unpackPhase" "buildPhase" "installPhase" ];

    buildPhase = ''
      set -x;
      echo "whoami result..."
      whoami;

      # tar vxzf nbdkit-1.40.4.tar.gz

      echo 'date' > fmd_nbdkit;

      ls -l >> to_cp;
      echo >> to_cp;
      pwd >> to_cp;
      echo >> to_cp;
      # tree >> to_cp;
      echo >> to_cp;
      # ls -l /usr/bin 2> &1 >> to_cp;
      command -v env >> to_cp
      command -v sed >> to_cp
      command -v bash >> to_cp
      command -v patchShebangs >> to_cp

      # echo $PATH >> to_cp;

      chown -R $(whoami) .

      # this is done with one of the othe build phases 
      # ./configure

      # ${pkgs.bash}/bin/bash
      # sed -i '''1d''' docs/make-links.sh;
      # sed -i '''1i#!${pkgs.bash}/bin/bash''' docs/make-links.sh
      patchShebangs --build docs/make-links.sh 

      # use three single quotes to escape the center quote
      # sed -i '''1d''' common/protocol/generate-protostrings.sh 
      # sed -i '''1i#!${pkgs.bash}/bin/bash''' common/protocol/generate-protostrings.sh 
      patchShebangs --build common/protocol/generate-protostrings.sh 

      mkdir -p $out/lib/nbdkit/plugins

      # this is broken? 
      make 2>&1 | tee make_log;
      set +x
    '';

    installPhase = ''
      mkdir -p $out/bin;

      chmod u+x fmd_nbdkit;

      cp fmd_nbdkit $out/bin/;
      cp to_cp $out/
      cp make_log $out/

      # mkdir $out/stuff;
      # cp -ar * $out/stuff/

      # cp server/nbdkit $out/bin/
      # cp -r docs $out/
      # cp -r plugins $out/

      # find . | grep -v tests | awk '/plugin.so/{ print "cp " $0 " $out/lib/nbdkit/plugins" }' | bash 
      find . | grep -v tests | awk ''\'/plugin.so/{ print "cp " $0 " $out/lib/nbdkit/plugins" }''\' | bash 

      cp -r * $out/bin/
      cp -r server/nbdkit $out/bin/
    '';
  };
in {
  environment.systemPackages = [xxx];
}
