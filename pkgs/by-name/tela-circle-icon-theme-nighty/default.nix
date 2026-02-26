{
  tela-circle-icon-theme,
  source
}:
tela-circle-icon-theme.overrideAttrs (p: {
  inherit (source) src;
  version = "${source.date}-unstable";
})
