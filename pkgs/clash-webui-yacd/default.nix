{
  source,
  lib,
  unzip,
  stdenv
}:
stdenv.mkDerivation rec {
  inherit (source) pname version src;

  nativeBuildInputs = [ unzip ];
  unpackPhase = ''
    unzip $src
  '';
  sourceRoot = "yacd-${version}";

  installPhase = ''
    mkdir -p $out/share/clash/ui
    cp -r * $out/share/clash/ui
  '';

  meta = with lib; {
    description = "Yet Another Clash Dashboard";
    homepage = "https://github.com/haishanh/yacd";
    license = licenses.mit;
  };
}
