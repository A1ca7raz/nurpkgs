{
  kdePackages,
}:
kdePackages.dolphin.overrideAttrs (p: {
  version = "${p.version}-fix-space";

  patches = [ ./00-dolphin-return-space.patch ];
})
