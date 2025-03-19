{
  pkgs ? import <nixpkgs> { },
  specialArgs ? {}
}:
let
  inherit (import ./lib/packages.nix { inherit pkgs specialArgs; })
    mapPackages callPackage;
in
mapPackages callPackage "function" ./pkgs
