{
  lib ? (import <nixpkgs> {}).lib,
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix lib) ];
  }
}:
(import ./lib/collect_packages.nix { inherit lib; }).mapPackages
  (name: vaule: pkgs.${name})
  "path" ./pkgs
