{
  ungoogled-chromium
}:
(ungoogled-chromium.override {
  enableWideVine = true;
}).overrideAttrs (p: {
  version = "${p.version}-custom";
  __intentionallyOverridingVersion = true;
})
