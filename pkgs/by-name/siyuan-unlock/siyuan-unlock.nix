# https://github.com/demoshang/siyuan-patch
{
  callPackage,
  applyPatches,
  siyuan,
}:
let
  # Local nvfetcher pin (see ./nvfetcher.toml); the patch set tags follow
  # the siyuan version being built, so it stays pinned to nixpkgs' siyuan.
  sources = callPackage ./_sources/generated.nix { };
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
in
siyuan.overrideAttrs (p: {
  version = "${p.version}-unlock";
  kernel = p.kernel.overrideAttrs (pp: {
    src = patchedSrc;
    sourceRoot = "${patchedSrc.name}/kernel";
  });
  __intentionallyOverridingVersion = true;
})
