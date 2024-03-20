{
  stdenv,
  source,
  cmake,
  extra-cmake-modules,
  kdePackages,
  kwin,
  lib
}:
stdenv.mkDerivation rec {
  inherit (source) pname src version;

  nativeBuildInputs = [ cmake extra-cmake-modules kdePackages.wrapQtAppsHook ];
  buildInputs = [ kwin ];

  cmakeFlags = [
    "-DCMAKE_INSTALL_PREFIX=$out"
    "-DBUILD_TESTING=OFF"
    "-DKDE_INSTALL_USE_QT_SYS_PATHS=ON"
  ];
}
