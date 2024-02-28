{
  homepage-dashboard
}:
(homepage-dashboard.override {
  enableLocalIcons = true;
}).overrideAttrs (p: {
  postBuild = p.postBuild + ''
    patch -p1 .next/standalone/server.js -i ${./allow_env_hostname.patch}
  '';
})
