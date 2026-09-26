{
  nurpkgs.packages.ungoogled-chromium-drm = { ungoogled-chromium }:
    ungoogled-chromium.override {
      enableWideVine = true;
    };
}
