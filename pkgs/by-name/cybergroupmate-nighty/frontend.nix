{
  lib,
  source,
  fetchPnpmDeps,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenv
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (source) src;
  pname = "cybergroupmate-frontend-nighty";
  version = "${source.date}-unstable";

  sourceRoot = "${finalAttrs.src.name}/src/dashboard/ui";

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-SLBtfDuhSodH8G8nQ9DY2wDYlq4WytqMxDjAbqZ74K8=";
    sourceRoot = "${finalAttrs.src.name}/src/dashboard/ui";
  };

  buildPhase = ''
    runHook preBuild

    npx vite build --outDir dist

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -r dist/* $out/

    runHook postInstall
  '';
})
