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
  sourceRoot = "clash-dashboard-gh-pages";

  installPhase = ''
    mkdir -p $out/share/clash/ui
    cp -r * $out/share/clash/ui
  '';

  meta = with lib; {
    description = "Web Dashboard for Clash";
    homepage = "https://github.com/Dreamacro/clash-dashboard";
    license = licenses.mit;
  };
}