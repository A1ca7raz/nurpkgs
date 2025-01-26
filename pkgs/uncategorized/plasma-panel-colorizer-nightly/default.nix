{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  kdePackages,
  nix-update-script,
  source,
  python3
}:
let
  pyEnv = python3.withPackages (pythonPackages: with pythonPackages; [
    dbus-python
    pygobject3
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "plasma-panel-colorizer";
  version = "2.0.0-unstable";

  inherit (source) src;

  nativeBuildInputs = [
    cmake
    kdePackages.extra-cmake-modules
  ];

  buildInputs = [
    kdePackages.plasma-desktop
  ];

  strictDeps = true;

  cmakeFlags = [
    (lib.cmakeBool "INSTALL_PLASMOID" true)
    (lib.cmakeBool "BUILD_PLUGIN" true)
    (lib.cmakeFeature "Qt6_DIR" "${kdePackages.qtbase}/lib/cmake/Qt6")
  ];

  dontWrapQtApps = true;

  passthru.updateScript = nix-update-script { };

  postInstall = ''
    chmod +x $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/ui/tools/*
    sed -i 's/<default>python3<\/default>/<default>${lib.escape ["/"] (lib.getExe pyEnv)}<\/default>/' $out/share/plasma/plasmoids/luisbocanegra.panel.colorizer/contents/config/main.xml
  '';
})
