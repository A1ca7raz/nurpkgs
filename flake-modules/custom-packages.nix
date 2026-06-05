{ inputs, lib, ... }:
let
  nurpkgs = pkgs: import ../. {
    inherit pkgs lib;
    specialArgs = { inherit inputs; };
  };
in {
  perSystem = { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        config.allowUnfree = true;
        inherit system;
      };
    in {
      _module.args.pkgs = pkgs;

      packages = nurpkgs pkgs;
    };
}
