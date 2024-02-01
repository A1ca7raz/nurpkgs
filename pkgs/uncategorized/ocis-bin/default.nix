{
  source,
  lib,
  stdenv
}:
stdenv.mkDerivation {
  inherit (source) pname version src;
  dontUnpack = true;
  installPhase = ''
    install -D $src $out/bin/ocis
  '';

  meta = with lib; {
    description = "ownCloud Infinite Scale Stack";
    homepage = "https://github.com/owncloud/ocis";
    license = licenses.asl20;
  };
}
