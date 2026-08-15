# https://github.com/demoshang/siyuan-patch
{
  siyuan
}:
let
  unlock_patches = builtins.map (p: ./patches/${p}) [
    "default-config.patch"
    "disable-update.patch"
    "mock-vip-user.patch"
  ];
in
siyuan.overrideAttrs (p: {
  version = "${p.version}-unlock";
  kernel = p.kernel.overrideAttrs (pp: {
    patches = pp.patches ++ unlock_patches;
  });
  __intentionallyOverridingVersion = true;
})
