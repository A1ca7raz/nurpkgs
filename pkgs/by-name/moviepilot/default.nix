{
  lib,
  stdenv,
  inputs,
  sources,
  bash,
  python312,
  playwright-driver,
  mkYarnPackage,
  fetchYarnDeps,
  callPackage
}:
let
  plugins = sources.moviepilot-plugins.src;
  resources = sources.moviepilot-resources.src;

  inherit (inputs)
    uv2nix
    pyproject-nix
    pyproject-build-systems
  ;

  workspace = uv2nix.lib.workspace.loadWorkspace { workspaceRoot = ./.; };

  overlay = workspace.mkPyprojectOverlay {
    sourcePreference = "wheel";
  };

  pyprojectOverrides = import ./pyproject-overrides.nix;

  pythonSet =
    (callPackage pyproject-nix.build.packages {
      python = python312;
    }).overrideScope (
      lib.composeManyExtensions [
        pyproject-build-systems.overlays.default
        overlay
        pyprojectOverrides
      ]
    );

  env = pythonSet.mkVirtualEnv "moviepilot-env" workspace.deps.default;
in
stdenv.mkDerivation rec {
  pname = "moviepilot";
  inherit (sources.moviepilot-core) version src;

  patchPhase = ''
    runHook prePatch

    # install -Dm644 ${plugins}/plugins/* app/plugins
    # cp -r ${plugins}/plugins.v2/* app/plugins
    cp -r ${resources}/resources/* app/helper

    runHook postPatch
  '';

  buildInputs = [
    playwright-driver.browsers
    env
  ];

  buildPhase = ''
    runHook preBuild

    python -m compileall .

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib
    mkdir -p $out/bin

    cp -r app/ $out/lib/
    cp -r database/ $out/lib/
    cp -r config/ $out/lib/
    cp -r __pycache__/ $out/lib/
    cp app.ico $out/lib/
    cp setup.py $out/lib/
    cp version.py $out/lib/
    cp requirements.in $out/lib/
    cp requirements.txt $out/lib/
    cp safety.policy.yml $out/lib/
    cp frozen.spec $out/lib/

    cat > $out/bin/moviepilot <<- EOF
    #!${bash}/bin/bash

    export PYTHONPATH=$out/lib

    export PLAYWRIGHT_BROWSERS_PATH=${playwright-driver.browsers}
    export PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS=true

    ${env}/bin/python $out/lib/app/main.py \$@
    EOF
    chmod +x $out/bin/moviepilot

    runHook postInstall
  '';

  passthru.frontend = mkYarnPackage rec {
    inherit (sources.moviepilot-frontend) pname src version;

    packageJSON = "${src}/package.json";

    offlineCache = fetchYarnDeps {
      yarnLock = "${src}/yarn.lock";
      hash = "sha256-YYjeQO6p2jZ7G+TR7qHy5w5hk7SYGG9PmdW94oAM1O8=";
    };

    prePatch = ''
      mkdir public/plugin_icon
      cp ${plugins}/icons/* public/plugin_icon
    '';

    buildPhase = ''
      runHook preBuild

      yarn --offline build

      runHook postBuild
    '';

    preBuild = ''
      # FIXME: WTF??
      cd deps/moviepilot/
      rm node_modules
      ln -s ../../node_modules/ node_modules

      yarn --offline postinstall
    '';

    doDist = false;

    installPhase = ''
      runHook preInstall

      mkdir $out
      cp -r dist/* $out/

      runHook postInstall
    '';
  };

  meta = {
    description = "NAS媒体库自动化管理工具";
    homepage = "https://github.com/jxxghp/MoviePilot";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ ];
    mainProgram = "moviepilot";
  };
}
