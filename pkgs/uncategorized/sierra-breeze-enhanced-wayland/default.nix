{
  sierra-breeze-enhanced
}:
sierra-breeze-enhanced.overrideAttrs (p: {
  patches = [ ./fix-wayland.patch ];
})
