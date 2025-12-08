{
  mpv-unwrapped
}:
(mpv-unwrapped.override {
  vapoursynthSupport = true;
}).overrideAttrs (p: {
  version = "${p.version}-vapoursynth";
  __intentionallyOverridingVersion = true;
})
