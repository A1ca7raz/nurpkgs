let
  inherit (builtins)
    length
    split
    elemAt
    pathExists
  ;
in rec {
  is = _regex: _str: length (split _regex _str) != 1;

  isNix = is "\\.nix$";

  removeNix = x: elemAt (split "\\.nix$" x) 0;

  addNix = x: x + ".nix";

  hasDefault = n: pathExists /${n}/default.nix;
}
