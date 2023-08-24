{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Packages from other flakes
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nvfetcher = {
      url = "github:berberman/nvfetcher";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-compat.follows = "flake-compat";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    with builtins; let
      inherit (import ./config.nix) meta extraPackages;
      lib = nixpkgs.lib;
      utils = import ./lib lib;
      system = [ "x86_64-linux" ];
      overlay = import ./overlay.nix;
    in
    flake-utils.lib.eachSystem system (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            overlay
            inputs.nvfetcher.overlays.default
          ];
        };
        nurpkgs = import ./. { inherit pkgs; };
        inherit (pkgs) mkShell;
        unfreePkgs = extraPackages pkgs;

        nvfetcher = inputs.nvfetcher.packages.${system}.default;
      in rec {
        legacyPackages = (flake-utils.lib.filterPackages pkgs.system (nurpkgs))
          // unfreePkgs
          // inputs.sops-nix.packages.${system}
          // inputs.nvfetcher.packages.${system};
        packages = legacyPackages;
        checks = legacyPackages;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = mkShell { nativeBuildInputs = [ nvfetcher ]; };
        apps.update = {
          type = "app";
          program = (pkgs.writeShellScript "script" ''
            ${nvfetcher}/bin/nvfetcher -o pkgs/_sources "$@"
          '').outPath;
        };
    }) // {
      overlay = self.overlays.default;
      overlays.default = overlay;
      overlays.nvfetcher = inputs.nvfetcher.overlays.default;

      nixosModule = self.nixosModules.default;
      nixosModules.default = { ... }: {
        imports = utils.importsDirs ./modules;
        nixpkgs.overlays = [
          self.overlays.default
          self.overlays.nvfetcher
        ];
        nix.settings = {
          substituters = [ meta.cache ];
          trusted-public-keys = [ meta.pubkey ];
        };
      };
    };
}
