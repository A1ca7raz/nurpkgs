{
  source,
  miraclecast
}:
miraclecast.overrideAttrs (p: {
  inherit (source) version src;
})
