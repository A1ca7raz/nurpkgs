{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    hub.url = "github:A1ca7raz/inputs-hub";
    nixpkgs.follows = "hub/nixpkgs";
    flake-utils.follows = "hub/flake-utils";

    spicetify.follows = "hub/spicetify-nix";
    nixpak.follows = "hub/nixpak";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, nixpak, ... }:
    let
      lib = nixpkgs.lib;
      utils = import ./lib lib;
      systems = [
        "x86_64-linux"
      ];
      overlay = import ./overlay.nix { inherit lib; };
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
          overlays = [
            overlay
            self.overlays.nixpaks
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
        customPackages = flake-utils.lib.filterPackages system nurpkgs;
      in rec {
        legacyPackages = customPackages // nixpakPackages;
        packages = legacyPackages;

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

      nixosModule = self.nixosModules.default;
      nixosModules.default = { ... }: {
        imports = utils.importsDirs ./modules;
        nixpkgs.overlays = [
          self.overlays.default
          (f: p: {
            inherit (self.packages.x86_64-linux)
              spicetify
            ;
          })
        ];
      };
    };
}
