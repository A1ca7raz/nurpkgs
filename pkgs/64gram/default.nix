{
  source,
  qt6Packages
}:
qt6Packages.callPackage ./telegram.nix {
  inherit source;
}