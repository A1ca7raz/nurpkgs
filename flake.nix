{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-23-05.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Dependencies of 3rd-party flakes
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };

    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    napalm = {
      url = "github:nix-community/napalm";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
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
    authentik-nix = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.flake-parts.follows = "flake-parts";
      inputs.flake-compat.follows = "flake-compat";
      inputs.nixpkgs-23-05.follows = "nixpkgs-23-05";
      inputs.poetry2nix.follows = "poetry2nix";
      inputs.napalm.follows = "napalm";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, nvfetcher, ... }:
    let
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
        authentikPackages = inputs.authentik-nix.packages.${system};
      in rec {
        legacyPackages = customPackages //
          unfreePackages //
          sopsPackages //
          nvfetcherPackages //
          authentikPackages;
        packages = legacyPackages;
        packageBundles = utils.mkPackageBundles pkgs ./pkgs // {
          inherit
            unfreePackages
            customPackages
            nvfetcherPackages
            sopsPackages
            authentikPackages;
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
