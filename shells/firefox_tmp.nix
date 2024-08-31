# simple.nix
with (import <nixpkgs> {});
mkShell {
  buildInputs = [
	firefox 
  ];
  shellHook = ''
  	cp -ar ~/.mozilla/firefox_profile /tmp/firefox-profile-tmp
  	firefox --profile /tmp/firefox-profile-tmp; exit; 
  '';
}

