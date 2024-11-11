{
  source,
  baidupcs-go
}:
baidupcs-go.overrideAttrs (p: {
  inherit (source) src;
})
