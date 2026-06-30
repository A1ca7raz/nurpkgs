{
  lib,
  stdenv,
  scdoc,
  gnumake,
  source
}:
stdenv.mkDerivation {
  inherit (source) pname src;
  version = "${source.date}-unstable";

  nativeBuildInputs = [
    scdoc
    gnumake
  ];

  buildPhase = ''
    make
  '';

  installPhase = ''
    export PREFIX=$out
    make install
  '';
}
