{
  mpv
}:
(mpv.override {
  vapoursynthSupport = true;
}).overrideAttrs (p: {
  version = "${p.version}-vapoursynth";
  __intentionallyOverridingVersion = true;
  nativeInstallCheckInputs = [];  # Skip versionCheck
})
