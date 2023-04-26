{
  source,
  lib,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;
  dontUnpack = true;
  installPhase = ''
    install -Dm644 $src $out/share/clash/GeoIP.dat
  '';

  meta = with lib; {
    description = "Enhanced edition of GeoIP files for Clash.";
    homepage = "https://github.com/Loyalsoldier/geoip";
    license = licenses.cc-by-sa-40;
  };
}