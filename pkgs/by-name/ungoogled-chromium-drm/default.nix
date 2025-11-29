{
  ungoogled-chromium
}:
(ungoogled-chromium.override {
  enableWideVine = true;
}).overrideAttrs (p: {
  version = "${p.version}-custom";
})
