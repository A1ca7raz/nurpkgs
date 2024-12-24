{
  baidupcs-go
}:
baidupcs-go.overrideAttrs (p: {
  postInstall = p.postInstall + ''
    ln -s $out/bin/Baidupcs-Go $out/bin/baidupcs-go
  '';
})
