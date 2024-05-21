{pkgs ? import <nixpkgs> {}}:
pkgs.stdenv.mkDerivation {
  name = "update_nebula";
  src = builtins.fetchGit {
    url = "https://github.com/yeltnar/nebula-ansible";
  };

  unpackPhase = ''
    # cd src;
    bash -c "ls -l; cat env-vars; echo src $src; echo; ls $src" > update_nebula;
  '';

  # buildPhase = ''
  #   bash -c 'ls -l;' > update_nebula;
  # '';

  installPhase = ''
    mkdir -p $out/bin;
    cp update_nebula $out/bin/;
  '';
}
