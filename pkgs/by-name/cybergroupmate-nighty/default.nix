{
  source,
  lib,
  callPackage,
  fetchPnpmDeps,
  nodejs,
  node-gyp,
  sqlite,
  python3,
  srcOnly,
  gnumake,
  pnpm_11,
  removeReferencesTo,
  pnpmConfigHook,
  makeWrapper,
  stdenv
}:
let
  pnpm = pnpm_11;
  nodeSources = srcOnly nodejs;

  frontend = callPackage ./frontend.nix {
    inherit source;
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (source) src;
  pname = "cybergroupmate-core-nighty";
  version = "${source.date}-unstable";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
    makeWrapper
    python3
    sqlite
    gnumake
    node-gyp
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-2WgD872lsp/c6ITlSuJkWA13KYtyGlgOhGQF2U0DXi0=";
  };

  buildPhase = ''
    runHook preBuild

    # build better-sqlite3
    betterSqlitePath="node_modules/better-sqlite3"
    pushd "$betterSqlitePath"
    npm run build-release --offline --nodedir="${nodeSources}"
    rm -rf build/Release/{.deps,obj,obj.target,test_extension.node}
    find build -type f -exec \
      ${lib.getExe removeReferencesTo} -t "${nodeSources}" {} \;
    popd

    # build node-pty
    nodePtyPath="node_modules/node-pty"
    pushd "$nodePtyPath"
    npm run install --offline --nodedir="${nodeSources}"
    rm -rf build/Release/{.deps,obj,obj.target,test_extension.node}
    find build -type f -exec \
      ${lib.getExe removeReferencesTo} -t "${nodeSources}" {} \;
    popd

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    mkdir -p $out/share/cybergroupmate

    # install CGM core
    cp -r node_modules $out/share/cybergroupmate
    cp -r src $out/share/cybergroupmate
    cp -r system-prompts $out/share/cybergroupmate
    cp package.json $out/share/cybergroupmate

    # install CGM frontend
    ln -s ${frontend} $out/share/cybergroupmate/src/dashboard/public

    makeWrapper ${nodejs}/bin/node $out/bin/cybergroupmate \
      --add-flags $out/share/cybergroupmate/node_modules/tsx/dist/cli.mjs \
      --add-flags $out/share/cybergroupmate/src/main.ts \
      --prefix PATH : ${nodejs}/bin
    ln -s $out/bin/cybergroupmate $out/bin/cgm

    runHook postInstall
  '';

  passthru = {
    inherit frontend;
  };
})
