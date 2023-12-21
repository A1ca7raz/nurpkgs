{ lib, ... }:
with builtins; with lib; let
  inherit (import ./nix.nix { inherit lib; }) isNix removeNix hasDefault;
in rec {
  mkPackageTree = type: path:
  let
    _getter = n: if type == "function" then import n else n;

    _scan_first = mapAttrs' (_recur path) (readDir path);
    _scan = dir: mapAttrs' (_recur dir) (readDir dir);

    _recur = path: n: v:
    let
      realpath = /${path}/${n};
    in
      if v == "directory" && ! hasPrefix "_" n  && hasDefault realpath
      then { name = n; value = _getter realpath;}
      else if v == "regular" && ! hasPrefix "_" n  && isNix realpath
      then { name = removeNix n; value = _getter realpath;}
      else if v == "directory" && ! hasPrefix "_" n 
      then { name = n; value = _scan realpath; }
      else { name = removeNix n; value = null; };
  in 
    filterAttrsRecursive (n: v: v != null) _scan_first;

  flatPackages = type: path:
  let
    _getter = n: if type == "function" then import n else n;

    _scan_first = mapAttrsToList (_recur path) (readDir path);
    _scan = dir: mapAttrsToList (_recur dir) (readDir dir);

    _recur = path: n: v:
    let
      realpath = /${path}/${n};
    in
      if v == "directory" && ! hasPrefix "_" n  && hasDefault realpath
      then { name = n; value = _getter realpath;}
      else if v == "regular" && ! hasPrefix "_" n  && isNix realpath
      then { name = removeNix n; value = _getter realpath;}
      else if v == "directory" && ! hasPrefix "_" n 
      then _scan realpath
      else [];
  in 
    listToAttrs (flatten _scan_first);

  mapPackages = f: type: path: mapAttrs f (flatPackages type path);
}
