{
  stdenv,
  lib,
  fetchpatch,
  source
}:
stdenv.mkDerivation {
  inherit (source) pname version src;

  patch = fetchpatch {
    url = "https://patch-diff.githubusercontent.com/raw/dhruv8sh/plasma6-window-title-applet/pull/41.patch";
    hash = "sha256-b0/WXkG5MTq1LNab9fY/gAjvGIQ4FnghtF3yYctD5aM=";
  };

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/share/plasma/plasmoids/org.kde.windowtitle
    cp -r $src/* $out/share/plasma/plasmoids/org.kde.windowtitle

    rm $out/share/plasma/plasmoids/org.kde.windowtitle/install.sh
    rm $out/share/plasma/plasmoids/org.kde.windowtitle/README.md
  '';
}
