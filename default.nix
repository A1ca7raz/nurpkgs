{
  lib ? (import <nixpkgs> {}).lib,
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix lib) ];
  },
  specialArgs ? {}
}:
(import ./lib/collect_packages.nix { inherit lib specialArgs; }).mapPackages
  (name: vaule: pkgs.${name})
  "path" ./pkgs
