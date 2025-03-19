{
  kdePackages,
  source
}:
kdePackages.sierra-breeze-enhanced.overrideAttrs (p: {
  inherit (source) src version;
})
