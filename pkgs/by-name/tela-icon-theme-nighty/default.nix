{
  tela-icon-theme,
  source
}:
tela-icon-theme.overrideAttrs (p: {
  inherit (source) src;
  version = "${source.date}-unstable";
})
