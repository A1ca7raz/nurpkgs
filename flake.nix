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

  outputs = inputs@{ self, nixpkgs, flake-utils, nvfetcher, ... }:
    with builtins; let
      inherit (import ./config.nix) substituters trusted-public-keys extraPackages;
      lib = nixpkgs.lib;
      utils = import ./lib lib;
      system = [ "x86_64-linux" ];
      overlay = import ./overlay.nix lib;
    in
    flake-utils.lib.eachSystem system (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
          overlays = [
            overlay
            nvfetcher.overlays.default
          ];
        };
        nurpkgs = import ./. { inherit pkgs; };
        inherit (pkgs) mkShell;

        # Groups of nur packages
        customPackages = flake-utils.lib.filterPackages pkgs.system (nurpkgs);
        unfreePackages = extraPackages pkgs;
        nvfetcherPackages = nvfetcher.packages.${system};
        sopsPackages = inputs.sops-nix.packages.${system};
      in rec {
        legacyPackages = customPackages //
          unfreePackages //
          sopsPackages //
          nvfetcherPackages;
        packages = legacyPackages;
        packageBundles = utils.mkPackageBundles pkgs ./pkgs // {
          inherit
            unfreePackages
            customPackages
            nvfetcherPackages
            sopsPackages;
          ciPackages = nvfetcherPackages // sopsPackages;
        };
        checks = legacyPackages;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = mkShell { nativeBuildInputs = [ nvfetcherPackages.default ]; };
        apps.update = {
          type = "app";
          program = (pkgs.writeShellScript "script" ''
            ${nvfetcherPackages.default}/bin/nvfetcher -o pkgs/_sources "$@"
          '').outPath;
        };
      }
    ) // {
      overlay = self.overlays.default;
      overlays.default = overlay;
      overlays.nvfetcher = nvfetcher.overlays.default;

      nixosModule = self.nixosModules.default;
      nixosModules.default = { ... }: {
        imports = utils.importsDirs ./modules;
        nixpkgs.overlays = [
          self.overlays.default
          self.overlays.nvfetcher
        ];
        nix.settings = {
          inherit substituters trusted-public-keys;
        };
      };
    };
}
