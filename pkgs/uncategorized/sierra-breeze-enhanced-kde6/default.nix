{
  stdenv,
  source,
  cmake,
  kdePackages,
  lib
}:
stdenv.mkDerivation rec {
  inherit (source) pname src version;

  nativeBuildInputs = with kdePackages; [ cmake extra-cmake-modules wrapQtAppsHook ];
  buildInputs = with kdePackages; [
    kwin
    kwindowsystem
  ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DBUILD_TESTING=OFF"
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
  ];
}
