{
  source,
  lib,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;
  dontUnpack = true;
  installPhase = ''
    install -Dm644 $src $out/share/clash/GeoSite.dat
  '';

  meta = with lib; {
    description = "Enhanced edition of Clash rules dat files.";
    homepage = "https://github.com/Loyalsoldier/v2ray-rules-dat";
    license = licenses.gpl3;
  };
}