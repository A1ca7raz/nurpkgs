{
  source,
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  unzip,
  dbus,
  libsForQt5,
  xorg
}:
stdenv.mkDerivation rec {
  inherit (source) pname version src;

  nativeBuildInputs = [
    cmake unzip
  ];
  unpackPhase = ''
    unzip $src
  '';
  sourceRoot = "yet-another-spotify-tray-main";

  buildInputs = with libsForQt5; [
    dbus
    xorg.libX11
    xorg.libSM
    qt5.qtbase
    qt5.qttools
    qt5.wrapQtAppsHook
  ];

  meta = with lib; {
    description = "Tray icon for Spotify Linux client application";
    homepage = "https://github.com/macdems/yet-another-spotify-tray";
    license = licenses.mit;
  };
}
