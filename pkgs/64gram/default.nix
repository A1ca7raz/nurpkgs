{
  source,
  lib,
  fetchurl,
  stdenv,
  unzip,
  glibc,
  glib,
  fontconfig,
  freetype,
  libglvnd,
  xorg,
  dbus,
  xkeyboard_config,
  desktop-file-utils,
  wayland,
  qt6,
  glibmm,
  gtk3,
  libdbusmenu,
  lz4,
  xxHash,
  ffmpeg,
  openalSoft,
  minizip,
  libopus,
  alsa-lib,
  libpulseaudio,
  pipewire,
  range-v3,
  tl-expected,
  hunspell,
  glibmm_2_68,
  webkitgtk_6_0,
  jemalloc,
  rnnoise,
  protobuf,
  util-linuxMinimal,
  pcre,
  libselinux,
  libsepol,
  libepoxy,
  at-spi2-core,
  libthai,
  libdatrie,
  libsysprof-capture,
  libpsl,
  brotli,
  microsoft_gsl,
  rlottie
}:
let
  url_git = "https://github.com/TDesktop-x64/tdesktop";

  desktop = fetchurl {
    url = "${url_git}/raw/dev/lib/xdg/io.github.tdesktop_x64.TDesktop.desktop";
    sha256 = "sha256-wXpY19P3MMPKeSS0e7jQqIUXE1f7XN3DWVufaPQpoBg=";
  };

  icon = fetchurl {
    url = "${url_git}/raw/dev/Telegram/Resources/art/icon256.png";
    sha256 = "sha256-P7FADH3Ju8O1yz/+3L9KmwnFPii1en/zOoprkEiGQJA=";
  };

  app = source.src;

  srcs = [desktop icon app];

  rpath = lib.makeLibraryPath [
    glib
    fontconfig
    freetype
    libglvnd
    xorg.libxcb
    xorg.libX11
    dbus
    xkeyboard_config
    desktop-file-utils
    wayland
    qt6.qtbase
    qt6.qtwayland
    qt6.qtsvg
    qt6.qtimageformats
    qt6.qt5compat
    glibmm
    gtk3
    libdbusmenu
    lz4
    xxHash
    ffmpeg
    openalSoft
    minizip
    libopus
    alsa-lib
    libpulseaudio
    pipewire
    range-v3
    tl-expected
    hunspell
    glibmm_2_68
    webkitgtk_6_0
    jemalloc
    rnnoise
    protobuf
    util-linuxMinimal
    pcre
    xorg.libpthreadstubs
    xorg.libXdamage
    xorg.libXdmcp
    libselinux
    libsepol
    libepoxy
    at-spi2-core
    xorg.libXtst
    libthai
    libdatrie
    libsysprof-capture
    libpsl
    brotli
    microsoft_gsl
    rlottie
  ];
in
stdenv.mkDerivation {
  inherit (source) pname version;
  inherit srcs;
  dontBuild = true;
  nativeBuildInputs = [
    unzip
    qt6.qtbase
    qt6.wrapQtAppsHook
    # autoPatchelfHook
  ];

  unpackPhase = ''
    unzip ${app}
  '';
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/share/pixmaps
    mkdir -p $out/share/applications
    mkdir -p $out/share/icons/hicolor/256x256/apps

    cp ./Telegram $out/bin/telegram-desktop
    cp ${icon} $out/share/pixmaps/telegram.png
    cp ${icon} $out/share/icons/hicolor/256x256/apps/telegram.png

    cp ${desktop} $out/share/applications/telegram.desktop
    sed -i 's/@CMAKE_INSTALL_FULL_BINDIR@\///g' $out/share/applications/telegram.desktop
  '';
  postFixup = ''
    patchelf --set-interpreter ${glibc}/lib/ld-linux-x86-64.so.2 "$out/bin/telegram-desktop"
    patchelf --set-rpath ${rpath} "$out/bin/telegram-desktop"
  '';
}
