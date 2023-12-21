lib: final: prev:
let
  inherit (import ./lib/collect_packages.nix { inherit lib; })
    mapPackages callPackage;
in mapPackages (callPackage final) "function" ./pkgs
