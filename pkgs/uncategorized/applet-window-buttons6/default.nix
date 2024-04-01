{
  stdenv,
  source,
  lib,
  kdePackages,
  cmake
}:
stdenv.mkDerivation rec {
  inherit (source) pname src version;

  nativeBuildInputs = with kdePackages; [
    cmake
    extra-cmake-modules
    wrapQtAppsHook
  ];

  buildInputs = with kdePackages; [
    kcoreaddons
    kdeclarative
    kdecoration
    libplasma
  ];
}
