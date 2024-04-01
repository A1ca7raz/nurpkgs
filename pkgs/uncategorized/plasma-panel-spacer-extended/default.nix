{
  source,
  lib,
  stdenv,
  cmake,
  kdePackages,
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = with kdePackages; [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    libplasma
    qtdeclarative
    kdeplasma-addons
  ];

  cmakeFlags = [
    "-DBUILD_PLUGIN=OFF"
    "-DCMAKE_INSTALL_PREFIX=$out"
  ];
}
