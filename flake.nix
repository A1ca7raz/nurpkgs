{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    hub.url = "github:A1ca7raz/inputs-hub";
    nixpkgs.follows = "hub/nixpkgs";
    flake-utils.follows = "hub/flake-utils";
    flake-parts.follows = "hub/flake-parts";

    spicetify.follows = "hub/spicetify-nix";
    nixpak.follows = "hub/nixpak";
  };

  outputs = inputs@{ nixpkgs, flake-utils, nixpak, hub, ... }:
    let
      systems = [
        "x86_64-linux"
      ];
      specialArgs = { inherit inputs; };

      nurpkgs = pkgs: import ./. { inherit pkgs specialArgs; };
    in flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };
      in rec {
        legacyPackages = nurpkgs pkgs;
        packages = legacyPackages;

        checks = legacyPackages;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = pkgs.mkShell {
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
    ) // rec {
      overlays.default = final: nurpkgs;

      nixosModules = hub.nixosModules // {
        default = { ... }: {
          imports = [
            hub.nixosModules.helper
          ];

          nixpkgs.overlays = [
            overlays.default
          ];
        };
      };

      homeModules = hub.homeModules;
    };

  nixConfig = {
    extra-substituters = [
      # "https://cache.garnix.io"
      "https://a1ca7raz-nur.cachix.org"
    ];

    extra-trusted-public-keys = [
      # "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "a1ca7raz-nur.cachix.org-1:twTlSh62806B8lfG0QQzge4l5srn9Z8/xxyAFauOZnQ="
    ];
  };
}
