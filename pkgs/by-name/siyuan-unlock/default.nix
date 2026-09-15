# https://github.com/demoshang/siyuan-patch
{
  sources,
  applyPatches,
  siyuan,
}:
let
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
in
siyuan.overrideAttrs (p: {
  version = "${p.version}-unlock";
  kernel = p.kernel.overrideAttrs (pp: {
    src = patchedSrc;
    sourceRoot = "${patchedSrc.name}/kernel";
  });
  __intentionallyOverridingVersion = true;
})
