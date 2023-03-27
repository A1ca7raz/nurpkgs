{
  source,
  lib,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  installPhase = ''
    mkdir -p $out/share/clash-webui
    cp -r $src $out/share/clash-webui
  '';

  meta = with lib; {
    description = "Web Dashboard for Clash";
    homepage = "https://github.com/Dreamacro/clash-dashboard";
    license = licenses.mit;
  };
}