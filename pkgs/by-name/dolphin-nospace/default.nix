{
  kdePackages,
}:
kdePackages.dolphin.overrideAttrs (p: {
  version = "${p.version}-fix-space";
  __intentionallyOverridingVersion = true;

  patches = [ ./00-dolphin-return-space.patch ];
})
