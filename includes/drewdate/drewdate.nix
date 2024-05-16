{pkgs, ...}: let
  drewdate = pkgs.stdenv.mkDerivation {
    name = "drewdate";
    src = ./src;

    unpackPhase = ''
      mkdir -p src
    '';

    buildPhase = ''
      echo 'date' > drewdate;
      chmod +x drewdate
    '';

    installPhase = ''
      mkdir -p $out/bin;
      cp drewdate $out/bin/;
    '';
  };
in {
  environment.systemPackages = [drewdate];
}
