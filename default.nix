{
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix) ];
  }
}:
(import ./lib/map_packages.nix { inherit (pkgs) lib; }).mapPackages
  (name: pkgs.${name})
  ./pkgs
