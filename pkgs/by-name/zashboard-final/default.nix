{
  lib,
  stdenv
}:
stdenv.mkDerivation rec {
  pname = "zashboard-final";
  version = "2.6.0-no-fonts-final";

  src = ./zashboard-gh-pages-no-fonts;

  dontBuild = true;

  installPhase = ''
    mkdir -p $out
    cp -r $src/* $out/
  '';
}
