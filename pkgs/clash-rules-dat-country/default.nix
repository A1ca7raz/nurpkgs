{
  source,
  lib,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;
  dontUnpack = true;
  installPhase = ''
    install -Dm644 $src $out/etc/clash/Country.mmdb
  '';

  meta = with lib; {
    description = "Enhanced edition of MaxMind mmdb for Clash.";
    homepage = "https://github.com/Loyalsoldier/geoip";
    license = licenses.cc-by-sa-40;
  };
}