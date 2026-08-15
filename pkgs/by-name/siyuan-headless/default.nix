{
  lib,
  stdenv,
  makeWrapper,
  nodejs_22,
  pnpm_11,
  pnpmConfigHook,
  siyuan
}:

let
  pnpm = pnpm_11;

  unlock_patches = builtins.map (p: ../siyuan-unlock/patches/${p}) [
    "default-config.patch"
    "disable-update.patch"
    "mock-vip-user.patch"
  ];

  # Reuse the kernel definition maintained by nixpkgs, but drop its desktop-only
  # patch that hard-codes Pandoc into the binary. Upstream disables Pandoc in
  # Docker mode, so retaining that reference would only enlarge the closure.
  kernel = siyuan.kernel.overrideAttrs (oldAttrs: {
    patches = lib.filter
      (patch: !(lib.hasInfix "set-pandoc-path.patch" (toString patch)))
      (oldAttrs.patches or [ ]) ++ unlock_patches;
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

  doInstallCheck = true;
  installCheckPhase = ''
    runHook preInstallCheck

    test -f "$out/share/siyuan-headless/appearance/langs/en.json"
    test -f "$out/share/siyuan-headless/stage/build/desktop/index.html"
    test -f "$out/share/siyuan-headless/LICENSE"
    test -x "$out/share/siyuan-headless/kernel/SiYuan-Kernel"
    "$out/bin/siyuan-headless" --help >/dev/null

    runHook postInstallCheck
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
