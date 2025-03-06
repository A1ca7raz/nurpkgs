{ lib, specialArgs ? {}, ... }:
final: prev:
let
  inherit (import ./lib/collect_packages.nix { inherit lib specialArgs; })
    mapPackages callPackage;
in
  mapPackages (callPackage final) "function" ./pkgs
