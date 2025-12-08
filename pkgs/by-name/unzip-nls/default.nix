{
  unzip
}:
(unzip.override {
  enableNLS = true;
}).overrideAttrs (p: {
  version = "${p.version}-nls";
  __intentionallyOverridingVersion = true;
})
