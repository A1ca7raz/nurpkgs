{
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix) ];
  }
}:
(import ./lib/map_packages.nix {}).mapPackages
  (name: pkgs.${name})
  ./pkgs
