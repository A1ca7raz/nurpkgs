# https://github.com/Invisibox/nix-config/blob/main/modules/apps/orca/package.nix
{
  lib,
  source,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  atk,
  cairo,
  cups,
  dbus,
  expat,
  fontconfig,
  freetype,
  gdk-pixbuf,
  glib,
  gtk3,
  libappindicator-gtk3,
  libdrm,
  libGL,
  libgbm,
  libnotify,
  libsecret,
  libuuid,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxi,
  libxkbcommon,
  libxrandr,
  libxrender,
  libxscrnsaver,
  libxtst,
  nspr,
  nss,
  pango,
  udev,
  vulkan-loader,
  wayland,
  zlib,
  xdg-utils,
  wrapGAppsHook3,
  adwaita-icon-theme,
  gsettings-desktop-schemas,
  autoPatchelfHook,
  dpkg,
  stdenv
}:
let
  deps = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    atk
    cairo
    cups
    dbus
    expat
    fontconfig
    freetype
    gdk-pixbuf
    glib
    gtk3
    libappindicator-gtk3
    libdrm
    libGL
    libgbm
    libnotify
    libsecret
    libuuid
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxi
    libxkbcommon
    libxrandr
    libxrender
    libxscrnsaver
    libxtst
    nspr
    nss
    pango
    udev
    vulkan-loader
    wayland
    zlib
  ];

  rpath = lib.makeLibraryPath deps + ":" + lib.makeSearchPathOutput "lib" "lib64" deps;
  binpath = lib.makeBinPath [xdg-utils];
in
stdenv.mkDerivation {
  inherit (source) src pname version;

  nativeBuildInputs = [
    autoPatchelfHook
    dpkg
    wrapGAppsHook3
  ];

  buildInputs = deps ++ [
    adwaita-icon-theme
    gsettings-desktop-schemas
  ];

  dontConfigure = true;
  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack
    dpkg-deb --fsys-tarfile "$src" | tar --extract --no-same-owner --no-same-permissions
    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/opt" "$out/share"
    cp -R opt/* "$out/opt/"
    if [[ -d usr/share ]]; then
      cp -R usr/share/* "$out/share/"
    fi

    app_dir="$out/opt/Orca"
    chmod +x "$app_dir/orca-ide"

    makeWrapper "$app_dir/orca-ide" "$out/bin/orca" \
      --unset ELECTRON_RUN_AS_NODE

    sed -i 's#/opt/Orca/orca-ide#orca#g' $out/share/applications/orca-ide.desktop

    runHook postInstall
  '';

  preFixup = ''
    addAutoPatchelfSearchPath "$out/opt/Orca"

    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${rpath}:$out/opt/Orca
      --prefix PATH : ${binpath}
    )
  '';

  meta = with lib; {
    description = "Next-gen IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = licenses.mit;
    mainProgram = "orca";
    platforms = ["x86_64-linux"];
    sourceProvenance = with sourceTypes; [binaryNativeCode];
  };
}
