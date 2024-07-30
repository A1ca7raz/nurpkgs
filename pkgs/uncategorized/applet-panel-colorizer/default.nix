{
  stdenv,
  source,
  lib,
  kdePackages,
  cmake
}:
stdenv.mkDerivation {
  inherit (source) pname src version;

  dontWrapQtApps = true;

  nativeBuildInputs = with kdePackages; [
    cmake
    extra-cmake-modules
  ];

  buildInputs = with kdePackages; [
    libplasma
    plasma5support
  ];

  cmakeFlags = [
    "-DBUILD_PLUGIN=ON"
    "-DCMAKE_INSTALL_PREFIX=$out"
  ];

  postInstall = ''
    mkdir -p $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer
    cp -r $src/package/* $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer
  '';
}
