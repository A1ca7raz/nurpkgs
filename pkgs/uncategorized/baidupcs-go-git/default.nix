{
  source,
  baidupcs-go
}:
baidupcs-go.overrideAttrs (p: {
  inherit (source) src;

  postInstall = p.postInstall + ''
    ln -s $out/bin/Baidupcs-go $out/bin/baidupcs-go
  '';
})
