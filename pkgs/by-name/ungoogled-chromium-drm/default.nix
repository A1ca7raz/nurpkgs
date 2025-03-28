{
  ungoogled-chromium
}:
ungoogled-chromium.override {
  enableWideVine = true;
  commandLineArgs = [
    "--ozone-platform-hint=auto"  # Native Wayland
    "--enable-wayland-ime"  # Fcitx5

    # Touchpad Gestures for Navigation, Vaapi, Vulkan
    "--enable-features=TouchpadOverscrollHistoryNavigation,VaapiVideoDecodeLinuxGL,VaapiVideoDecoder,VaapiIgnoreDriverChecks,Vulkan,DefaultANGLEVulkan,VulkanFromANGLE"

    # FIXME: Disable popup shortcut setting window
    "--disable-features=GlobalShortcutsPortal"
  ];
}
