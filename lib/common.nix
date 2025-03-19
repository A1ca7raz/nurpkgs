let
  inherit (builtins)
    length
    split
    attrNames
    elemAt
    readDir
    foldl'
    pathExists
  ;
in rec {
  is = _regex: _str: length (split _regex _str) != 1;

  isNix = is "\\.nix$";

  removeNix = x: elemAt (split "\\.nix$" x) 0;

  addNix = x: x + ".nix";

  hasDefault = n: pathExists /${n}/default.nix;

  imports = path:
    let
      dir = readDir path;
    in foldl'
      (acc: n:
        if dir."${n}" == "directory" && pathExists /${path}/${n}/default.nix
        then acc ++ [ (import /${path}/${n}) ]
        else acc
      )
      []
      (attrNames dir);
}
