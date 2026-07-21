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
  pnpm,
  removeReferencesTo,
  pnpmConfigHook,
  makeWrapper,
  stdenv
}:
let
  nodeSources = srcOnly nodejs;

  frontend = callPackage ./frontend.nix {
    inherit source pnpm nodejs;
  };
in
stdenv.mkDerivation (finalAttrs: {
  inherit (source) src;
  pname = "cybergroupmate-nighty-unwrapped";
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

    mkdir -p $out

    # install CGM core
    cp -r node_modules $out/
    cp -r src $out/
    cp -r system-prompts $out/
    cp package.json $out/

    # install CGM frontend
    ln -s ${frontend} $out/src/dashboard/public

    runHook postInstall
  '';
})
