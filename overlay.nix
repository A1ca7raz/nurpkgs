lib: final: prev:
with builtins;
(import ./lib/collect_packages.nix { inherit lib; }).mapPackages (name: value:
  let
    sources = final.callPackage ./pkgs/_sources/generated.nix {};
    package = value;
    args = intersectAttrs
      (functionArgs package)
      { source = sources.${name}; };
  in
    (final.callPackage package args)
) "function" ./pkgs
