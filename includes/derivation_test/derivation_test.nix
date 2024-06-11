{ pkgs, ... }: let
  xxx = pkgs.stdenv.mkDerivation {
    name = "derivation_test";
    src = ./src;

    buildPhase = ''
      whoami;
      echo 'date' > date_derivation;
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
