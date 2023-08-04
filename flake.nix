{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Packages from other flakes
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    with builtins; let
      lib = nixpkgs.lib;
      meta = import ./meta.nix;
      utils = import ./lib lib;
      system = [ "x86_64-linux" ];
      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachSystem system (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ overlay];
        };
        nurpkgs = import ./. { inherit pkgs; };
        inherit (pkgs) mkShell;
        unfreePkgs = import ./extra.nix pkgs;
      in rec {
        legacyPackages = (flake-utils.lib.filterPackages pkgs.system (nurpkgs))
          // unfreePkgs
          // inputs.sops-nix.packages.${system};
        packages = legacyPackages;
        checks = legacyPackages;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = mkShell { nativeBuildInputs = with pkgs; [ nvfetcher ]; };
        apps.update = {
          type = "app";
          program = (pkgs.writeShellScript "script" ''
            ${pkgs.nvfetcher}/bin/nvfetcher -o pkgs/_sources "$@"
          '').outPath;
        };
    }) // {
      overlay = self.overlays.default;
      overlays.default = overlay;

      nixosModule = self.nixosModules.default;
      nixosModules.default = { ... }: {
        imports = utils.importsDirs ./modules;
        nixpkgs.overlays = [ self.overlay ];
        nix.settings = {
          substituters = [ meta.cache ];
          trusted-public-keys = [ meta.pubkey ];
        };
      };
    };
}
