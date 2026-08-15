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
    hash = "sha256-yxwJ8aHQNAl+bDCy+gSd+rL3KimPHnk9mfzpW4io0d8=";
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
    # Keep the native-module rebuild aligned with the Electron patch release
    # provided by nixpkgs. Otherwise the upstream exact-version check removes
    # the injected distribution and tries to download its package version.
    substituteInPlace config/scripts/rebuild-native-deps.mjs \
      --replace-fail \
        "const electronVersion = JSON.parse(
  readFileSync(resolve(electronPackageDir, 'package.json'), 'utf8')
).version" \
        "const electronVersion = '${electron.version}'"

    # v1.4.182 contains the paired-web host-selection tests but only part of
    # their implementation. Restore the missing upstream wiring so web clients
    # never fall back to the client machine's filesystem while the paired host
    # is unavailable.
    substituteInPlace src/renderer/src/components/sidebar/use-add-repo-host-selection.ts \
      --replace-fail \
        "import { translate } from '@/i18n/i18n'" \
        "import { translate } from '@/i18n/i18n'
import { isWebClientLocation } from '@/lib/web-client-location'" \
      --replace-fail \
        "  selectedHostId: ExecutionHostId" \
        "  selectedHostId: ExecutionHostId | null" \
      --replace-fail \
        "  const { hostOptions } = useSidebarHostScopeOptions()" \
        "  const { hostOptions } = useSidebarHostScopeOptions()
  const isWebClient = isWebClientLocation()" \
      --replace-fail \
        "        return (
          parsed?.kind !== 'runtime' || !ephemeralRuntimeEnvironmentIds.has(parsed.environmentId)
        )" \
        "        return (
          !(isWebClient && parsed?.kind === 'local') &&
          (parsed?.kind !== 'runtime' || !ephemeralRuntimeEnvironmentIds.has(parsed.environmentId))
        )" \
      --replace-fail \
        "    [ephemeralRuntimeEnvironmentIds, hostOptions]" \
        "    [ephemeralRuntimeEnvironmentIds, hostOptions, isWebClient]" \
      --replace-fail \
        "  const previousOpenRef = useRef(false)" \
        "  const previousOpenRef = useRef(false)
  const pairedWebRuntimeHost = isWebClient
    ? selectableHostOptions.find((host) => host.kind === 'runtime' && canSelectAddRepoHost(host))
    : undefined" \
      --replace-fail \
        "    ) ??
    selectableHostOptions.find(
      (host) => host.id === LOCAL_EXECUTION_HOST_ID && canSelectAddRepoHost(host)
    )" \
        "    ) ??
    pairedWebRuntimeHost ??
    selectableHostOptions.find(
      (host) => host.id === LOCAL_EXECUTION_HOST_ID && canSelectAddRepoHost(host)
    )" \
      --replace-fail \
        "        ? focusedHostId
        : LOCAL_EXECUTION_HOST_ID
      setSelectedAddProjectHostId(nextHostId)" \
        "        ? focusedHostId
        : (pairedWebRuntimeHost?.id ?? (isWebClient ? null : LOCAL_EXECUTION_HOST_ID))
      if (nextHostId) {
        setSelectedAddProjectHostId(nextHostId)
      }" \
      --replace-fail \
        "  }, [isOpen, selectableHostOptions, settings])" \
        "  }, [isOpen, isWebClient, pairedWebRuntimeHost?.id, selectableHostOptions, settings])"

    substituteInPlace src/renderer/src/components/sidebar/use-add-repo-host-selection.test.ts \
      --replace-fail \
        "  sshConnect: vi.fn(),
  sshGetState: vi.fn()
}))" \
        "  sshConnect: vi.fn(),
  sshGetState: vi.fn(),
  isWebClient: false
}))" \
      --replace-fail \
        "vi.mock('./use-sidebar-host-scope-options', () => ({
  useSidebarHostScopeOptions: () => ({ hostOptions: mocks.hostOptions })
}))" \
        "vi.mock('./use-sidebar-host-scope-options', () => ({
  useSidebarHostScopeOptions: () => ({ hostOptions: mocks.hostOptions })
}))

vi.mock('@/lib/web-client-location', () => ({
  isWebClientLocation: () => mocks.isWebClient
}))" \
      --replace-fail \
        "    mocks.sshGetState.mockReset()" \
        "    mocks.sshGetState.mockReset()
    mocks.isWebClient = false"

    substituteInPlace src/renderer/src/components/sidebar/AddRepoHostSelector.tsx \
      --replace-fail \
        "  selectedHostId: ExecutionHostId" \
        "  selectedHostId: ExecutionHostId | null"

    substituteInPlace src/renderer/src/components/sidebar/use-add-repo-host-change-reset.ts \
      --replace-fail \
        "  selectedHostId: string" \
        "  selectedHostId: string | null"

    substituteInPlace src/renderer/src/components/sidebar/AddRepoStartSteps.tsx \
      --replace-fail \
        "  canCreateProject?: boolean
  browseHostKind?: 'local' | 'ssh' | 'runtime'" \
        "  canCreateProject?: boolean
  actionsDisabled?: boolean
  browseHostKind?: 'local' | 'ssh' | 'runtime'" \
      --replace-fail \
        "  canCreateProject = true,
  browseHostKind = 'local'," \
        "  canCreateProject = true,
  actionsDisabled = false,
  browseHostKind = 'local'," \
      --replace-fail \
        "  const actionsRef = useRef<HTMLDivElement | null>(null)
  const { primaryAction, secondaryActions }" \
        "  const actionsRef = useRef<HTMLDivElement | null>(null)
  const actionsUnavailable = isAdding || actionsDisabled
  const { primaryAction, secondaryActions }" \
      --replace-fail \
        "  const [selectedKind, setSelectedKind] = useState<string | null>(primaryAction.kind)

  useEffect(() => {
    if (isAdding) {
      setSelectedKind(null)
      return
    }
    if (!isAdding) {
      browseActionRef.current?.focus()
    }
  }, [isAdding])" \
        "  const [selectedKind, setSelectedKind] = useState<string | null>(primaryAction.kind)
  const visibleSelectedKind = actionsUnavailable ? null : selectedKind

  useEffect(() => {
    if (!actionsUnavailable) {
      browseActionRef.current?.focus()
    }
  }, [actionsUnavailable])" \
      --replace-fail \
        "          disabled={isAdding}
          selected={selectedKind === primaryAction.kind}" \
        "          disabled={actionsUnavailable}
          selected={visibleSelectedKind === primaryAction.kind}" \
      --replace-fail \
        "                disabled={isAdding || Boolean(action.disabled)}
                selected={selectedKind === action.kind}" \
        "                disabled={actionsUnavailable || Boolean(action.disabled)}
                selected={visibleSelectedKind === action.kind}"

    substituteInPlace src/renderer/src/components/sidebar/AddRepoDialogStepContent.tsx \
      --replace-fail \
        "  canCreateProject?: boolean
  manualCreateParentEntry?: boolean" \
        "  canCreateProject?: boolean
  actionsDisabled?: boolean
  manualCreateParentEntry?: boolean" \
      --replace-fail \
        "  canCreateProject = true,
  manualCreateParentEntry = isRuntimeEnvironmentActive," \
        "  canCreateProject = true,
  actionsDisabled = false,
  manualCreateParentEntry = isRuntimeEnvironmentActive," \
      --replace-fail \
        "        canCreateProject={canCreateProject}
        browseHostKind={browseHostKind}" \
        "        canCreateProject={canCreateProject}
        actionsDisabled={actionsDisabled}
        browseHostKind={browseHostKind}"

    substituteInPlace src/renderer/src/components/sidebar/AddRepoDialog.tsx \
      --replace-fail \
        "            ?.label ?? hostSelection.selectedHostId" \
        "            ?.label ?? null" \
      --replace-fail \
        "        browseHostKind={
          selectedHostKind === 'ssh' || selectedHostKind === 'runtime' ? selectedHostKind : 'local'
        }" \
        "        actionsDisabled={!hostSelection.selectedHostId}
        browseHostKind={selectedHostKind ?? 'runtime'}" \
      --replace-fail \
        "        onBrowse={
          selectedHostKind === 'ssh'
            ? () => void handleOpenRemoteStep(hostSelection.selectedSshTargetId)
            : selectedHostKind === 'runtime'
              ? () => setStep('server-path')
              : handleBrowse
        }" \
        "        onBrowse={() => {
          const selectedHost = hostSelection.selectedParsedHost
          if (selectedHost?.kind === 'ssh') {
            void handleOpenRemoteStep(selectedHost.targetId)
          } else if (selectedHost?.kind === 'runtime') {
            setStep('server-path')
          } else if (selectedHost?.kind === 'local') {
            void handleBrowse()
          }
        }}" \
      --replace-fail \
        "        onOpenCloneStep={() => {
          setCloneError(null)" \
        "        onOpenCloneStep={() => {
          if (!hostSelection.selectedHostId) {
            return
          }
          setCloneError(null)" \
      --replace-fail \
        "        onOpenCreateStep={() => {
          setCreateError(null)" \
        "        onOpenCreateStep={() => {
          if (!hostSelection.selectedHostId) {
            return
          }
          setCreateError(null)"

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

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    pnpm exec vitest run \
      --config config/vitest.config.ts \
      src/renderer/src/components/sidebar/use-add-repo-host-selection.test.ts

    runHook postCheck
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
