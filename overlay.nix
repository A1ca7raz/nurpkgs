final: prev:
with builtins; let
  path = ./pkgs;
in
(import ./lib/map_packages.nix {}).mapPackages (name:
  let
    sources = final.callPackage /${path}/_sources/generated.nix {};
    package = import /${path}/${name};
    args = intersectAttrs
      (functionArgs package)
      { source = sources.${name}; };
  in
    final.callPackage package args
) /${path}
