{
  lib,
  stdenv,
  sources,
  applyPatches,
  makeWrapper,
  nodejs_22,
  pnpm_11,
  pnpmConfigHook,
  siyuan,
}:
let
  pnpm = pnpm_11;

  # https://github.com/demoshang/siyuan-patch
  # Upstream tags its patch set after the siyuan version it applies to,
  # so the tag always follows the siyuan version being built.
  patchRepo = sources.siyuan-patch.src;
  patchedSrc = applyPatches {
    name = "siyuan-${siyuan.version}-patched";
    src = siyuan.src;
    patches = map (f: "${patchRepo}/patches/siyuan/${f}") [
      "default-config.patch"
      "disable-update.patch"
      "mock-vip-user.patch"
    ];
  };

  # Reuse the kernel definition maintained by nixpkgs, but drop its desktop-only
  # patch that hard-codes Pandoc into the binary. Upstream disables Pandoc in
  # Docker mode, so retaining that reference would only enlarge the closure.
  kernel = siyuan.kernel.overrideAttrs (oldAttrs: {
    src = patchedSrc;
    sourceRoot = "${patchedSrc.name}/kernel";
    patches = lib.filter
      (patch: !(lib.hasInfix "set-pandoc-path.patch" (toString patch)))
      (oldAttrs.patches or [ ]);
  });
in
stdenv.mkDerivation (finalAttrs: {
  pname = "siyuan-headless";
  inherit (siyuan) src pnpmDeps;
  version = "${siyuan.version}-unlock";

  sourceRoot = "${finalAttrs.src.name}/app";

  nativeBuildInputs = [
    makeWrapper
    nodejs_22
    pnpm
    pnpmConfigHook
  ];

  buildPhase = ''
    runHook preBuild

    pnpm run build
    node scripts/trimChangelogs.js

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    appDir="$out/share/siyuan-headless"
    mkdir -p "$appDir/kernel" "$out/bin"
    cp -r appearance stage guide "$appDir/"
    install -Dm755 ${kernel}/bin/kernel "$appDir/kernel/SiYuan-Kernel"

    makeWrapper "$appDir/kernel/SiYuan-Kernel" "$out/bin/siyuan-headless" \
      --set RUN_IN_CONTAINER true \
      --add-flags serve \
      --add-flags "--wd=$appDir" \
      --inherit-argv0

    runHook postInstall
  '';

  meta = {
    description = "Headless browser server for SiYuan";
    homepage = "https://b3log.org/siyuan/";
    changelog = "https://github.com/siyuan-note/siyuan/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Plus;
    mainProgram = "siyuan-headless";
    platforms = lib.platforms.linux;
  };
})
