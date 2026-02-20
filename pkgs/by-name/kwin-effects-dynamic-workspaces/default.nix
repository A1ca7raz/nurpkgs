{
  fetchFromGitHub,
  lib,
  stdenv,
  source
}:
stdenv.mkDerivation rec {
  inherit (source) pname src;
  version = "${source.date}-unstable";

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/kwin/effects/${pname}
    cp -r $src/contents $out/share/kwin/effects/${pname}/
    cp $src/metadata.json $out/share/kwin/effects/${pname}/
    cp $src/LICENSE $out/share/kwin/effects/${pname}/
  '';
}
