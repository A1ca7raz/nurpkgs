{
  kdePackages,
  source,
  fetchpatch
}:
kdePackages.sierra-breeze-enhanced.overrideAttrs (p: {
  inherit (source) src;
  version = "${p.version}-unstable";
})
