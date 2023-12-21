{
  pkgs ? import <nixpkgs> {
    overlays = [ (import ./overlay.nix) ];
  }
}:
(import ./lib/collect_packages.nix { inherit (pkgs) lib; }).mapPackages
  (name: vaule: pkgs.${name})
  "path" ./pkgs
