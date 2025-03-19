{ pkgs, specialArgs ? {}, ... }:
let
  inherit (import ./common.nix)
    isNix
    removeNix
    hasDefault
  ;

  inherit (pkgs.lib)
    mapAttrsToList
    hasPrefix
    listToAttrs
    flatten
    intersectAttrs
  ;

  inherit (builtins)
    readDir
    mapAttrs
    isFunction
    functionArgs
  ;

  _flatPackages = _getter: path:
    let
      _scan_first = mapAttrsToList (_recur path) (readDir path);
      _scan = dir: mapAttrsToList (_recur dir) (readDir dir);

      _recur = path: n: v:
        let
          realpath = /${path}/${n};
        in
          if v == "directory" && ! hasPrefix "_" n  && hasDefault realpath
          then { name = n; value = _getter n realpath;}
          else if v == "regular" && ! hasPrefix "_" n  && isNix realpath
          then { name = removeNix n; value = _getter n realpath;}
          else if v == "directory" && ! hasPrefix "_" n
          then _scan realpath
          else [];
    in
      listToAttrs (flatten _scan_first);
in rec {

  flatPackages = type:
    let
      _getter = n: p:
        if type == "function" then import p else p;
    in
      _flatPackages _getter;

  mapPackages = f: type: path: mapAttrs f (flatPackages type path);

  callPackage = name: value:
    let
      sources = pkgs.callPackage ../pkgs/_sources/generated.nix {};
      package = if isFunction value then value else import value;
      args = intersectAttrs
        (functionArgs package)
        (specialArgs // {
          source = sources.${name};
          inherit sources pkgs;
        });
    in
      pkgs.callPackage package args;
}
