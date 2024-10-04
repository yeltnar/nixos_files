{ pkgs, ... }: let
  nbdkit = pkgs.stdenv.mkDerivation {
    name = "nbdkit";

    buildInputs = [
      pkgs.libgcc 
      pkgs.gnumake 
      pkgs.perl
      pkgs.autoconf
      pkgs.automake
      pkgs.bash
    ];

    src = builtins.fetchTarball {
      url = "https://download.libguestfs.org/nbdkit/1.40-stable/nbdkit-1.40.4.tar.gz";
      sha256 = "03zh028dpmv2wkx4v0kbxkaxxpscjnhzpcdyn3f09fb4icji3550";
    };

    buildPhase = ''

      patchShebangs --build docs/make-links.sh 
      patchShebangs --build common/protocol/generate-protostrings.sh 

      make;
    '';

    installPhase = ''
      mkdir -p $out/bin;
      mkdir -p $out/lib/nbdkit/plugins
      mkdir -p $out/share/bash-completion/completions/

      # copy the bash completions
      cp bash-completion/nbdkit $out/share/bash-completion/completions/

      # move the plugins to the directory that is expected 
      find . | grep -v tests | awk ''\'/plugin.so/{ print "cp " $0 " $out/lib/nbdkit/plugins" }''\' | bash 

      # copy the binary... 
      # the one in the root points here for some reason, but the link doesn't make it out of the build env
      cp -r server/nbdkit $out/bin/
    '';
  };
in {
  environment.systemPackages = [nbdkit];
}
