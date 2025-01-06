{
  baidupcs-go
}:
baidupcs-go.overrideAttrs (p: {
  postInstall = p.postInstall + ''
    ln -s $out/bin/BaiduPCS-Go $out/bin/baidupcs-go
  '';
})
