{ lib, ... }:
{
  isNix = x: lib.hasSuffix ".nix" x;
  removeNix = x: lib.removeSuffix ".nix" x;
  addNix = x: x + ".nix";

  hasDefault = n: builtins.pathExists /${n}/default.nix;
}