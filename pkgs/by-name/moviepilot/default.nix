{ autoPatchelfHook
, bash
, buildNpmPackage
, curl
, ffmpeg
, fuse3
, gh
, git
, inputs
, iproute2
, jq
, lib
, lsof
, makeWrapper
, netcat
, nodejs_24
, openssh
, patchelf
, pkgs
, procps
, python312
, rclone
, ripgrep
, rsync
, source
, sources
, stdenv
, unar
, unzip
, wget
,
}:
let
  workspace = inputs.uv2nix.lib.workspace.loadWorkspace {
    workspaceRoot = ./python;
  };

  pythonOverlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  legacySetuptoolsOverlay = final: prev:
    lib.genAttrs [
      "aliyun-python-sdk-core"
      "anitopy"
      "crcmod"
      "http-ece"
      "oss2"
      "pinyin2hanzi"
    ]
      (name:
        prev.${name}.overrideAttrs (old: {
          nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ final.resolveBuildSystem {
            setuptools = [ ];
          };
        }));

  pythonBase = pkgs.callPackage inputs.pyproject-nix.build.packages {
    python = python312;
  };

  pythonSet = pythonBase.overrideScope (
    lib.composeManyExtensions [
      inputs.pyproject-build-systems.overlays.wheel
      pythonOverlay
      legacySetuptoolsOverlay
    ]
  );

  pythonEnv = pythonSet.mkVirtualEnv "moviepilot-python-env" workspace.deps.default;

  frontendRuntime = buildNpmPackage {
    pname = "moviepilot-frontend-runtime";
    version = lib.removePrefix "v" sources.moviepilot-frontend.version;
    src = ./frontend;

    nodejs = nodejs_24;
    npmDepsHash = "sha256-1shhCS7E9BD/8CVZlFGeDhqLolubPmAKEoql4rUynaE=";

    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -r node_modules "$out/node_modules"
      runHook postInstall
    '';
  };

  runtimePath = lib.makeBinPath [
    bash
    curl
    ffmpeg
    fuse3
    gh
    git
    iproute2
    jq
    lsof
    netcat
    nodejs_24
    openssh
    procps
    rclone
    ripgrep
    rsync
    unar
    unzip
    wget
  ];

  resourceArch =
    if stdenv.hostPlatform.isAarch64 then
      "aarch64-linux-gnu"
    else
      "x86_64-linux-gnu";
in
assert source.version == sources.moviepilot-frontend.version;
stdenv.mkDerivation {
  inherit (source) pname src;
  version = lib.removePrefix "v" source.version;

  nativeBuildInputs = [
    autoPatchelfHook
    jq
    makeWrapper
    patchelf
    unzip
  ];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    appDir="$out/share/moviepilot"
    mkdir -p "$appDir"
    cp -r . "$appDir"

    # Match the plugin merge performed by the official container build.
    cp -r ${sources.moviepilot-plugins.src}/plugins.v2/. "$appDir/app/plugins/"
    jq -r 'to_entries[] | select(.value.v2 == true) | .key | ascii_downcase' \
      ${sources.moviepilot-plugins.src}/package.json \
      | while IFS= read -r plugin; do
          if [ ! -d "$appDir/app/plugins/$plugin" ] && [ -d "${sources.moviepilot-plugins.src}/plugins/$plugin" ]; then
            cp -r "${sources.moviepilot-plugins.src}/plugins/$plugin" "$appDir/app/plugins/$plugin"
          fi
        done

    # Ship the frontend release and the two Node modules used by service.js.
    mkdir -p "$TMPDIR/moviepilot-frontend"
    unzip -q ${sources.moviepilot-frontend.src} -d "$TMPDIR/moviepilot-frontend"
    cp -r "$TMPDIR/moviepilot-frontend/dist" "$appDir/public"
    cp -r ${frontendRuntime}/node_modules "$appDir/public/node_modules"

    # MoviePilot loads a platform-specific site adapter from app/helper.
    install -Dm644 \
      ${sources.moviepilot-resources.src}/resources.v2/user.sites.v2.bin \
      "$appDir/app/helper/user.sites.v2.bin"
    install -Dm755 \
      ${sources.moviepilot-resources.src}/resources.v2/sites.cpython-312-${resourceArch}.so \
      "$appDir/app/helper/sites.cpython-312-${resourceArch}.so"

    # The upstream binary carries a CI-only RUNPATH.
    patchelf --remove-rpath "$appDir/app/helper/sites.cpython-312-${resourceArch}.so"

    makeWrapper ${pythonEnv}/bin/python "$out/bin/moviepilot" \
      --chdir "$appDir" \
      --add-flags "-m app.cli" \
      --prefix PATH : ${runtimePath} \
      --set-default FRONTEND_PATH "$appDir/public" \
      --set-default MOVIEPILOT_AUTO_UPDATE false \
      --set-default VENV_PATH ${pythonEnv} \
      --run 'if [ -z "''${CONFIG_DIR-}" ]; then export CONFIG_DIR="''${XDG_CONFIG_HOME:-$HOME/.config}/moviepilot"; fi'

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck
    export HOME="$TMPDIR/home"
    export CONFIG_DIR="$TMPDIR/config"
    mkdir -p "$HOME"
    "$out/bin/moviepilot" version
    "$out/bin/moviepilot" --help >/dev/null
    runHook postInstallCheck
  '';

  meta = {
    description = "NAS media library automation management tool";
    homepage = "https://github.com/jxxghp/MoviePilot";
    changelog = "https://github.com/jxxghp/MoviePilot/releases/tag/${source.version}";
    license = lib.licenses.gpl3Only;
    mainProgram = "moviepilot";
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
  };
}
