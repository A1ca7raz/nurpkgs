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
    crane = {
      url = "github:ipetkov/crane";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hercules-ci-effects = {
      url = "github:hercules-ci/hercules-ci-effects";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # Packages from other flakes
    # FIXME: rollback sops-nix to fix breaking changes
    sops-nix = {
      url = "github:Mic92/sops-nix/59d6988329626132eaf107761643f55eb979eef1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#     nvfetcher = {
#       url = "github:berberman/nvfetcher";
#       inputs.nixpkgs.follows = "nixpkgs";
#       inputs.flake-utils.follows = "flake-utils";
#       inputs.flake-compat.follows = "flake-compat";
#     };
    spicetify-nix = {
      url = "github:A1ca7raz/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      inputs.crane.follows = "crane";
      inputs.rust-overlay.follows = "rust-overlay";
      inputs.pre-commit-hooks-nix.follows = "";
    };
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.hercules-ci-effects.follows = "hercules-ci-effects";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, nixpak, ... }:
    let
      inherit (import ./config.nix)
        extraPackages
        jetbrainsPackages;
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
            self.overlays.nixpaks
#             nvfetcher.overlays.default
          ];
        };
        nurpkgs = import ./. { inherit pkgs lib; };
        inherit (pkgs) mkShell;

        mkNixPak = nixpak.lib.nixpak {
          inherit (pkgs) lib;
          inherit pkgs;
        };

        nixpakPackages = utils.mapPackages (
          name: vaule:
            (mkNixPak {
              config = vaule;
            }).config.env
        ) "function" ./pkgs/_nixpaks;

        # Groups of nur packages
        customPackages = flake-utils.lib.filterPackages pkgs.system (nurpkgs);
        unfreePackages = extraPackages pkgs;
#         nvfetcherPackages = nvfetcher.packages.${system};
        sopsPackages = inputs.sops-nix.packages.${system};
        spicetifyPackages = {
          spicetifyAll = inputs.spicetify-nix.checks.${system}.all-tests;
          spicetifyApps = inputs.spicetify-nix.checks.${system}.apps;
        };
        lanzabootePackages = inputs.lanzaboote.packages.${system};
        nixIndexDbPackages = inputs.nix-index-database.packages.${system};
        JetBrainsPackages = jetbrainsPackages pkgs;
      in rec {
        legacyPackages = customPackages //
          unfreePackages //
          sopsPackages //
#           nvfetcherPackages //
          spicetifyPackages //
          lanzabootePackages //
          nixIndexDbPackages //
          JetBrainsPackages //
          nixpakPackages;
        packages = legacyPackages;
        packageBundles = utils.mkPackageBundles pkgs ./pkgs // {
          inherit
            unfreePackages
            customPackages
#             nvfetcherPackages
            sopsPackages
            spicetifyPackages
            nixIndexDbPackages
            JetBrainsPackages
            nixpakPackages;
          ciPackages = sopsPackages;
          trivialPackages = spicetifyPackages //
            lanzabootePackages //
            nixIndexDbPackages;
        };
        checks = legacyPackages;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = mkShell {
          nativeBuildInputs = with pkgs; [
            nvfetcher
            nix-init
          ];
        };
        apps.update = {
          type = "app";
          program = (pkgs.writeShellScript "script" ''
            ${pkgs.nvfetcher}/bin/nvfetcher -o pkgs/_sources "$@"
          '').outPath;
        };
      }
    ) // {
      overlay = self.overlays.default;
      overlays.default = overlay;
      overlays.nixpaks = final: prev: {
        nixpaks = self.packageBundles.nixpakPackages;
      };
#       overlays.nvfetcher = nvfetcher.overlays.default;

      nixosModule = self.nixosModules.default;
      nixosModules.default = { ... }: {
        imports = utils.importsDirs ./modules;
        nixpkgs.overlays = [
          self.overlays.default
#           self.overlays.nvfetcher
        ];
        nix.settings = import ./substituters.nix;
      };
    };
}
