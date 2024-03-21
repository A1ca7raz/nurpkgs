{ lib
, stdenv
, fetchFromGitHub
, fetchpatch
, cmake
, libX11
, libXext
, gitUpdater
, kdePackages
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qtstyleplugin-kvantum";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "tsujan";
    repo = "Kvantum";
    rev = "V${finalAttrs.version}";
    hash = "sha256-i+QjVPSzWNPVQmQkB+u/3Wrvqqoz5OIjRdyZKXzxZh4=";
  };

  nativeBuildInputs = with kdePackages; [
    cmake
    qmake
    qttools
    wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    qtbase
    qtsvg
    libX11
    libXext
    kwindowsystem
    qtwayland ];

  sourceRoot = "${finalAttrs.src.name}/Kvantum";

  patches = [
    (fetchpatch {
      # add xdg dirs support
      url = "https://github.com/tsujan/Kvantum/commit/01989083f9ee75a013c2654e760efd0a1dea4a68.patch";
      hash = "sha256-HPx+p4Iek/Me78olty1fA0dUNceK7bwOlTYIcQu8ycc=";
      stripLen = 1;
    })
  ];

  postPatch = ''
    substituteInPlace style/CMakeLists.txt \
      --replace-fail '"''${_Qt6_PLUGIN_INSTALL_DIR}/' "\"$out/$qtPluginPrefix/" \
      --replace-fail '"''${_Qt5_PLUGIN_INSTALL_DIR}/' "\"$out/$qtPluginPrefix/"
  '';

  passthru.updateScript = gitUpdater {
    rev-prefix = "V";
  };

  meta = with lib; {
    description = "SVG-based Qt5 theme engine plus a config tool and extra themes";
    homepage = "https://github.com/tsujan/Kvantum";
    license = licenses.gpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ romildo Scrumplex ];
  };
})
