{
  source,
  lib,
  at-spi2-core,
  electron_43,
  fetchPnpmDeps,
  gdk-pixbuf,
  gsettings-desktop-schemas,
  gobject-introspection,
  harfbuzz,
  gtk3,
  makeWrapper,
  nodejs_24,
  pango,
  patchelf,
  pnpm_10,
  pnpmConfigHook,
  python3,
  wrapGAppsHook3,
  wl-clipboard,
  xclip,
  xdg-utils,
  xdotool,
  xorg-server,
  enableWayland ? true,
  enableXorg ? false,
  headless ? false,
  stdenv
}:
let
  electron = electron_43;
  nodejs = nodejs_24;
  pnpm = pnpm_10;
  python = python3.withPackages (ps: [ ps.pygobject3 ]);
  electronBuilderArch = if stdenv.hostPlatform.isAarch64 then "arm64" else "x64";
  unpackedDir = if stdenv.hostPlatform.isAarch64 then "linux-arm64-unpacked" else "linux-unpacked";

  runtimePackages =
    lib.optionals enableWayland [ wl-clipboard ]
    ++ lib.optionals enableXorg [
      xclip
      xdotool
    ]
    ++ lib.optional headless xorg-server;

  runtimePath = lib.makeBinPath runtimePackages;

  guiRuntimePath = lib.makeBinPath [ xdg-utils ];

  typelibPath = lib.makeSearchPath "lib/girepository-1.0" (map lib.getLib [
    at-spi2-core
    gdk-pixbuf
    gobject-introspection
    harfbuzz
    gtk3
    pango
  ]);
in
stdenv.mkDerivation (finalAttrs: {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 3;
    hash = "sha256-px81uOohjemi0a3HRTr/cbA3Xm+cY+RMhqP5k8eQuck=";
  };

  nativeBuildInputs = [
    makeWrapper
    nodejs
    patchelf
    pnpm
    pnpmConfigHook
    python
    wrapGAppsHook3
  ];

  buildInputs = [
    gsettings-desktop-schemas
    gtk3
  ];

  dontWrapGApps = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = "1";
    npm_config_build_from_source = "true";
    npm_config_nodedir = electron.headers;
  };

  postPatch = ''
    # Native modules use the glibc from this package's Nix closure, so the
    # upstream Ubuntu 20.04 compatibility gate does not apply.
    substituteInPlace config/electron-builder.config.cjs \
      --replace-fail \
        "if (context.electronPlatformName === 'linux') {" \
        "if (false && context.electronPlatformName === 'linux') {" \
      --replace-fail \
        "    '!resources/skills/**'," \
        "    '!resources/skills/**',
    // Nix supplies relay as extraResources; do not retain another ASAR copy.
    '!out/relay{,/**/*}',
    // Vite emits these assets into both renderer bundles. The source copies
    // have no main-process runtime consumer in the Linux package.
    '!resources/{claude.webp,ghostty.svg,gremlin.webp,gwindows_logo.svg,logo.svg,minimax-icon.svg,openclaude-logo.png,opencode.webp}',
    '!resources/darwin{,/**/*}',
    '!resources/icon-source{,/**/*}',
    '!resources/linux/packaging{,/**/*}'," \
      --replace-fail \
        "    'resources/**'," \
        "    'resources/tray/**',"

    # Keep the bundled Computer Use Python out of the application-wide PATH so
    # notebooks and PTYs continue to resolve the user's Python.
    substituteInPlace src/main/computer/desktop-script-provider-bridge.ts \
      --replace-fail \
        "const command = platform === 'windows' ? 'powershell.exe' : 'python3'" \
        "const command = platform === 'windows' ? 'powershell.exe' : '${python}/bin/python3'" \
      --replace-fail \
        "env: process.env," \
        "env: platform === 'linux' ? { ...process.env, GI_TYPELIB_PATH: '${typelibPath}' } : process.env,"
  '';

  buildPhase = ''
    runHook preBuild

    mkdir -p node_modules/electron/dist
    cp -r ${electron.dist}/. node_modules/electron/dist/
    chmod -R u+w node_modules/electron/dist
    printf '%s' electron > node_modules/electron/path.txt

    ORCA_FORCE_NATIVE_REBUILD=1 node config/scripts/rebuild-native-deps.mjs
    pnpm run build

    # Keep the custom Electron distribution outside the project tree so the
    # broad electron-builder files glob cannot pack a second copy into app.asar.
    electronDist="$TMPDIR/orca-electron-dist"
    cp -r ${electron.dist} "$electronDist"
    chmod -R u+w "$electronDist"
    pnpm exec electron-builder \
      --dir \
      --config config/electron-builder.config.cjs \
      --config.electronDist="$electronDist" \
      --config.electronVersion=${electron.version}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share"
    cp -r dist/${unpackedDir} "$out/share/orca-ide"

    patchelf \
      --set-interpreter ${stdenv.cc.bintools.dynamicLinker} \
      "$out/share/orca-ide/resources/agent-browser-linux-${electronBuilderArch}"

    install -Dm644 resources/build/icon.png \
      "$out/share/icons/hicolor/1024x1024/apps/orca-ide.png"

    gappsWrapperArgsHook

    runtimeWrapperArgs=()
    ${lib.optionalString (runtimePackages != [ ]) ''
      runtimeWrapperArgs+=(--prefix PATH : ${runtimePath})
    ''}

    makeWrapper "$out/share/orca-ide/orca-ide" "$out/bin/orca-ide" \
      "''${gappsWrapperArgs[@]}" \
      "''${runtimeWrapperArgs[@]}" \
      --inherit-argv0 \
      --add-flags "--disable-features=FontDataServiceLinux" \
      --set CHROME_DEVEL_SANDBOX "$out/share/orca-ide/chrome-sandbox" \
      --set ORCA_TELEMETRY_DISABLED 1 \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --suffix PATH : ${guiRuntimePath}

    makeWrapper "$out/share/orca-ide/orca-ide" "$out/bin/orca" \
      "''${runtimeWrapperArgs[@]}" \
      --inherit-argv0 \
      --add-flags "$out/share/orca-ide/resources/app.asar.unpacked/out/cli/index.js" \
      --set CHROME_DEVEL_SANDBOX "$out/share/orca-ide/chrome-sandbox" \
      --set ELECTRON_RUN_AS_NODE 1 \
      --set ORCA_TELEMETRY_DISABLED 1

    mkdir -p $out/share/applications
    cat <<EOF > $out/share/applications/orca-ide.desktop
[Desktop Entry]
Name=Orca
Exec=orca %U
Terminal=false
Type=Application
Icon=orca-ide
StartupWMClass=orca
Comment=Next-gen IDE for parallel agentic development
Categories=Utility;
EOF

    runHook postInstall
  '';

  postFixup = ''
    # Electron's Nix derivation sets this after its own shrink-rpath pass so
    # libraries loaded with dlopen (EGL, Vulkan, PipeWire, etc.) remain visible.
    electronRpath="$(patchelf --print-rpath ${electron.dist}/electron)"
    patchelf --set-rpath "$electronRpath" "$out/share/orca-ide/orca-ide"

    glesRpath="$(patchelf --print-rpath ${electron.dist}/libGLESv2.so)"
    patchelf --set-rpath "$glesRpath" "$out/share/orca-ide/libGLESv2.so"

    # These private package CLIs are either never executed or are launched with
    # Electron's Node mode. Keep patch-shebangs from turning build-time Node.js
    # into a runtime dependency of the whole application.
    while IFS= read -r nodeScript; do
      substituteInPlace "$nodeScript" \
        --replace-fail '#!${nodejs}/bin/node' '#!/usr/bin/env node'
    done < <(grep -RIl '^#!${nodejs}/bin/node$' \
      "$out/share/orca-ide/resources/node_modules")

    # electron-builder copies complete npm packages as runtime resources.
    # Source maps and native build intermediates are not used at runtime.
    find "$out/share/orca-ide/resources/node_modules" \
      -type f -name '*.map' -delete

    nodePtyBuild="$out/share/orca-ide/resources/node_modules/node-pty/build"
    if [[ -d "$nodePtyBuild" ]]; then
      find "$nodePtyBuild" -type f \
        \( -name '*.d' -o -name '*.mk' -o -name '*.o' \
        -o -name Makefile -o -name config.gypi \) \
        -delete
      find "$nodePtyBuild" -depth -type d -empty -delete
    fi

    parcelModules="$out/share/orca-ide/resources/node_modules/@parcel"
    if [[ -d "$parcelModules" ]]; then
      find "$parcelModules" -mindepth 1 -maxdepth 1 -type d \
        -name 'watcher-linux-*-glibc' \
        ! -name 'watcher-linux-${electronBuilderArch}-glibc' \
        -exec rm -r {} +
    fi

    # These prebuilt addons load libstdc++ directly. electron-builder preserves
    # only their upstream $ORIGIN paths, which do not expose Nix's C++ runtime.
    cxxRpath='${lib.makeLibraryPath [ stdenv.cc.cc ]}'
    nativeRuntimeDirs=(
      "$out/share/orca-ide/resources/node_modules/@parcel/watcher-linux-${electronBuilderArch}-glibc"
      "$out/share/orca-ide/resources/node_modules/sherpa-onnx-linux-${electronBuilderArch}"
    )
    for nativeRuntimeDir in "''${nativeRuntimeDirs[@]}"; do
      [[ -d "$nativeRuntimeDir" ]] || continue
      while IFS= read -r -d "" nativeFile; do
        currentRpath="$(patchelf --print-rpath "$nativeFile")"
        patchelf --set-rpath "$cxxRpath:$currentRpath" "$nativeFile"
      done < <(
        find "$nativeRuntimeDir" -type f \
          \( -name '*.node' -o -name '*.so' -o -name '*.so.*' \) \
          -print0
      )
    done
  '';

  meta = {
    description = "Next-gen IDE for parallel agentic development";
    homepage = "https://github.com/stablyai/orca";
    license = lib.licenses.mit;
    mainProgram = "orca-ide";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      binaryNativeCode
    ];
  };
})
