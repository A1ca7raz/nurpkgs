{
  libsForQt5,
  fetchpatch
}:
libsForQt5.plasma-applet-virtual-desktop-bar.overrideAttrs (p: {
  buildInputs = p.buildInputs ++ [ libsForQt5.plasma-workspace ];

  patches = [
    (fetchpatch {
      url = "https://github.com/wsdfhjxc/virtual-desktop-bar/compare/master...lenonk:virtual-desktop-bar:12384281e68b77ba2911ba0ea2d183bdd6b41170.patch";
      hash = "sha256-tUIRIx42Fec/X1tEBQV7tqAoFJf+51YG30dtT1OopMg=";
    })
  ];

  meta = p.meta // {
    homepage = "https://github.com/lenonk/virtual-desktop-bar/tree/wayland";
  };
})
