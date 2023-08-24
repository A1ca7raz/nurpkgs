{ lib, ... }:
with builtins; rec {
  mkBundle = nixpkgs: name: pkgs:
  nixpkgs.stdenv.mkDerivation {
    inherit name;
    nativeBuildInputs =
      if isAttrs pkgs
      then attrValues pkgs
      else if isList pkgs
      then pkgs
      else throw "A list or a package set is required.";
    text = "";
  };

  mkPackageBundles = nixpkgs: mapAttrs (name: pkgs:
    mkBundle nixpkgs name pkgs
  );
}