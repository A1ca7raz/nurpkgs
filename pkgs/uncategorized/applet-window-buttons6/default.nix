{
  stdenv,
  source,
  lib,
  kdePackages,
  libsForQt5,
  cmake
}:
stdenv.mkDerivation rec {
  inherit (source) pname src version;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  buildInputs = with kdePackages; [
    kcoreaddons
    kdeclarative
    kdecoration
    libsForQt5.plasma-framework
  ];
}
