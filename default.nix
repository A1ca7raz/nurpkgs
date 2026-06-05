{
  pkgs ? import <nixpkgs> { },
  lib ? (import <nixpkgs> { }).lib,
  specialArgs ? {}
}:
let
  inherit (import ./lib/packages.nix { inherit pkgs lib specialArgs; })
    mapPackages callPackage;
in
mapPackages callPackage "function" ./pkgs
