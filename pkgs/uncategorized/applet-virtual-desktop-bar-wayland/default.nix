{
  libsForQt5,
  fetchpatch
}:
libsForQt5.plasma-applet-virtual-desktop-bar.overrideAttrs (p: {
  buildInputs = p.buildInputs ++ [ libsForQt5.plasma-workspace ];

  patches = [
    (fetchpatch {
      url = "https://github.com/wsdfhjxc/virtual-desktop-bar/compare/master...lenonk:virtual-desktop-bar:b6fc41959d95c8cca3d25aa2a201790fa391aab3.patch";
      hash = "sha256-hflgFDk45eBCa8ilR2D5a+3CoOZliskUuU6nKU3j43Q=";
    })
  ];

  meta = p.meta // {
    homepage = "https://github.com/lenonk/virtual-desktop-bar/tree/wayland";
  };
})
