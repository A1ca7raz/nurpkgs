{
  source,
  lib,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  installPhase = ''
    mkdir -p $out/share/clash/ui
    cp -r $src $out/share/clash/ui
  '';

  meta = with lib; {
    description = "Yet Another Clash Dashboard";
    homepage = "https://github.com/haishanh/yacd";
    license = licenses.mit;
  };
}