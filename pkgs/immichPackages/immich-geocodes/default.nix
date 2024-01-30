{
  lib,
  sources,
  unzip,
  stdenv
}:
let
  inherit (sources.geonames-cities500) version;

  admin1Codes = sources.geonames-admin1Codes.src;
  admin2Codes = sources.geonames-admin2Codes.src;
in stdenv.mkDerivation {
  pname = "immich-geocodes";
  inherit version;
  inherit (sources.geonames-cities500) src;

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/src/resources/
    unzip $src -d $out/src/resources/
    install -Dm444 "${admin1Codes.outPath}" $out/src/resources/admin1CodesASCII.txt
    install -Dm444 "${admin2Codes.outPath}" $out/src/resources/admin2Codes.txt
    echo ${version} > $out/src/resources/geodata-date.txt
  '';
}
