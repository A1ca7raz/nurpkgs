{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
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
    crane.url = "github:ipetkov/crane";
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
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kwin-effects-forceblur = {
      url = "github:taj-ny/kwin-effects-forceblur";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
    kwin-gestures = {
      url = "github:taj-ny/kwin-gestures";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.utils.follows = "flake-utils";
    };
#     nvfetcher = {
#       url = "github:berberman/nvfetcher";
#       inputs.nixpkgs.follows = "nixpkgs";
#       inputs.flake-utils.follows = "flake-utils";
#       inputs.flake-compat.follows = "flake-compat";
#     };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
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

    # Steal packages from others' nur
    nur-cryolitia = {
      url = "github:Cryolitia/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rust-overlay.follows = "rust-overlay";
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
        lanzabootePackages = inputs.lanzaboote.packages.${system};
        nixIndexDbPackages = inputs.nix-index-database.packages.${system};
        JetBrainsPackages = jetbrainsPackages pkgs;

        spicePkgs = inputs.spicetify-nix.legacyPackages.${system};
      in rec {
        legacyPackages = customPackages //
          unfreePackages //
          sopsPackages //
#           nvfetcherPackages //
          lanzabootePackages //
          nixIndexDbPackages //
          JetBrainsPackages //
          nixpakPackages // {
            kwin-effects-forceblur = pkgs.kdePackages.callPackage (inputs.kwin-effects-forceblur + "/package.nix") {};
            kwin-gestures = pkgs.kdePackages.callPackage (inputs.kwin-gestures + "/package.nix") {};
            spicetify = inputs.spicetify-nix.lib.mkSpicetify pkgs {
              enable = true;
              theme = spicePkgs.themes.dribbblish;
              colorScheme = "nord-light";

              enabledExtensions = with spicePkgs.extensions; [
                volumePercentage
                copyToClipboard
                playNext

                shuffle
                skipOrPlayLikedSongs
              ];
              enabledCustomApps = with spicePkgs.apps; [
                lyricsPlus
              ];
            };
          } // {
            inherit (inputs.nur-cryolitia.packages."${system}")
              maa-cli-nightly
            ;
          };
        packages = legacyPackages;
        packageBundles = utils.mkPackageBundles pkgs ./pkgs // {
          inherit
            unfreePackages
            customPackages
#             nvfetcherPackages
            sopsPackages
            nixIndexDbPackages
            JetBrainsPackages
            nixpakPackages;
          ciPackages = sopsPackages;
          trivialPackages = lanzabootePackages // nixIndexDbPackages;
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
          (f: p: {
            inherit (self.packages.x86_64-linux)
              kwin-effects-forceblur
              kwin-gestures
              maa-cli-nightly
              spicetify
            ;
          })
#           self.overlays.nvfetcher
        ];
        nix.settings = import ./substituters.nix;
      };
    };
}
