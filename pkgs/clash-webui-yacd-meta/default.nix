{
  source,
  lib,
  unzip,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [ unzip ];
  unpackPhase = ''
    unzip $src
  '';
  sourceRoot = "Yacd-meta-gh-pages";

  installPhase = ''
    mkdir -p $out/share/clash/ui
    cp -r * $out/share/clash/ui
  '';

  meta = with lib; {
    description = "Yet Another Clash Dashboard for Clash Meta";
    homepage = "https://github.com/MetaCubeX/Yacd-meta";
    license = licenses.mit;
  };
}
