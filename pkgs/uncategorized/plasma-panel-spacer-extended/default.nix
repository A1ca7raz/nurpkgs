{
  source,
  lib,
  stdenv,
  cmake,
  extra-cmake-modules,
  kdePackages,
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  nativeBuildInputs = [
    cmake
    extra-cmake-modules
  ];

  buildInputs = with kdePackages; [
    plasma-framework
    kdeplasma-addons
  ];

  cmakeFlags = [
    "-DBUILD_PLUGIN=OFF"
    "-DCMAKE_INSTALL_PREFIX=$out"
  ];
}
