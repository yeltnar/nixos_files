{
  stdenv,
  testers,
  fetchurl,
  autoreconfHook,
  makeWrapper,
  pkg-config,
  bash-completion,
  gnutls,
  libtool,
  curl,
  xz,
  zlib-ng,
  libssh,
  libnbd,
  lib,
  cdrkit,
  e2fsprogs,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "nbdkit";
  version = "1.40.4";

  src = fetchurl {
    url = "https://download.libguestfs.org/nbdkit/${lib.versions.majorMinor finalAttrs.version}-stable/nbdkit-${finalAttrs.version}.tar.gz";
    hash = "sha256-hGoc34F7eAvHjdQHxcquNJhpwpL5CLfv2DBZKVmpcpw=";
  };

  prePatch = ''
    # some scripts hardcore /usr/bin/env which is not available in the build env
    patchShebangs .
  '';

  strictDeps = true;

  nativeBuildInputs = [
    bash-completion
    autoreconfHook
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    bash-completion
    gnutls
    libtool
    curl
    xz
    zlib-ng
    libssh
    libnbd
    cdrkit
    e2fsprogs
  ];

  configureFlags = [
    "--disable-rust"
    "--disable-golang"
    "--disable-perl"
    "--disable-ocaml"
    "--disable-tcl"
    "--disable-lua"
    "--without-libguestfs"
    "--disable-example4"
    "--disable-floppy"
    "--with-iso"
  ];

  installFlags = [ "bashcompdir=$(out)/share/bash-completion/completions" ];

  passthru.tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

  meta = with lib; {
    homepage = "https://gitlab.com/nbdkit/nbdkit";
    description = "NBD server with stable plugin ABI and permissive license.";
    license = with licenses; bsd3;
    # maintainers = with maintainers; [ lukts30 ];
    platforms = with platforms; unix;
    mainProgram = "nbdkit";
  };
})

