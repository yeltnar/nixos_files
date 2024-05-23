{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "derivation_test";
  src = ./src;

  buildPhase = ''
    whoami;
    echo 'date' > r.sh;
  '';

  installPhase = ''
    mkdir -p $out/bin;
    cp r.sh $out/bin/;
  '';
}
