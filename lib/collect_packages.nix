{ lib, ... }:
with builtins; with lib; let
  inherit (import ./nix.nix { inherit lib; }) isNix removeNix hasDefault;
in rec {
  _mkPackageTree = _getter: path:
    let
      _scan_first = mapAttrs' (_recur path) (readDir path);
      _scan = dir: mapAttrs' (_recur dir) (readDir dir);

      _recur = path: n: v:
        let
          realpath = /${path}/${n};
        in
          if v == "directory" && ! hasPrefix "_" n  && hasDefault realpath
          then { name = n; value = _getter n realpath;}
          else if v == "regular" && ! hasPrefix "_" n  && isNix realpath
          then { name = removeNix n; value = _getter n realpath;}
          else if v == "directory" && ! hasPrefix "_" n 
          then { name = n; value = _scan realpath; }
          else { name = removeNix n; value = null; };
    in 
      filterAttrsRecursive (n: v: v != null) _scan_first;

  mkPackageTree = type:
    let
      _getter = n: p:
        if type == "function" then import p else p;
    in
      _mkPackageTree _getter;

  mkPackageBundles = pkgs: _mkPackageTree (callPackage pkgs);

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

  flatPackages = type:
    let
      _getter = n: p:
        if type == "function" then import p else p;
    in
      _flatPackages _getter;

  mapPackages = f: type: path: mapAttrs f (flatPackages type path);

  callPackage = pkgs: name: value:
    let
      sources = pkgs.callPackage ../pkgs/_sources/generated.nix {};
      package = if isFunction value then value else import value;
      args = intersectAttrs
        (functionArgs package)
        { source = sources.${name}; };
    in
      pkgs.callPackage package args;
}
