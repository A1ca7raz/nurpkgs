{ lib, ... }:
with builtins; rec {
  mkBundle = stdenv: name: pkgs:
  stdenv.mkDerivation {
    inherit name;
    nativeBuildInputs =
      if isAttrs pkgs
      then attrValues pkgs
      else if isList pkgs
      then pkgs
      else throw "A list or a package set is required.";
  };

  mkPackageBundles = stdenv: mapAttrs (name: pkgs:
    mkBundle stdenv name pkgs
  );
}