{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    # Basic flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils.url = "github:numtide/flake-utils";
    nix-std.url = "github:chessai/nix-std";

    # Dependencies of 3rd-party flakes
    crane.url = "github:ipetkov/crane";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    noctalia-qs = {
      url = "github:noctalia-dev/noctalia-qs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    npm-lockfile-fix = {
      url = "github:jeslie0/npm-lockfile-fix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # 3rd-party flakes
    colmena = {
      url = "github:zhaofengli/colmena";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
      inputs.flake-utils.follows = "flake-utils";
      inputs.nix-github-actions.follows = "";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    hermes-agent = {
      url = "github:NousResearch/hermes-agent";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.pyproject-build-systems.follows = "pyproject-build-systems";
      inputs.npm-lockfile-fix.follows = "npm-lockfile-fix";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    kimi-code = {
      url = "github:MoonshotAI/kimi-code";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hercules-ci-effects.follows = "";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.noctalia-qs.follows = "noctalia-qs";
    };
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "flake-utils/systems";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    let
      systems = [
        "x86_64-linux"
      ];
      specialArgs = { inherit inputs; };

      nurpkgs = pkgs: import ./. { inherit pkgs specialArgs; };
    in
    flake-utils.lib.eachSystem systems (system:
      let
        pkgs = import nixpkgs {
          config.allowUnfree = true;
          inherit system;
        };

        external = import ./lib/external.nix { inherit inputs pkgs system; };
        inherit (external) externalPackages externalBundles cachePackages;

        customPkgs = nurpkgs pkgs;

        allBundles = builtins.foldl' (acc: x: acc // x) {} externalBundles;
      in rec {
        legacyPackages = customPkgs // externalPackages;

        packages = cachePackages // customPkgs // externalPackages // allBundles;

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
    ) // {
      overlays.default = final: nurpkgs;
      overlays.external = final: prev: self.packages.x86_64-linux;

      nixosModules = with inputs; {
        colmena = colmena.nixosModules.deploymentOptions;
        disko = disko.nixosModules.disko;
        dms = dms.nixosModules.dank-material-shell;
        hermes = hermes-agent.nixosModules.default;
        home-manager = home-manager.nixosModules.home-manager;
        impermanence = impermanence.nixosModules.impermanence;
        lanzaboote = lanzaboote.nixosModules.lanzaboote;
        niri = { pkgs, lib, ... }: {
          imports = [
            niri-flake.nixosModules.niri
          ];

          programs.niri.package = pkgs.niri-unstable;
          programs.niri.settings.xwayland-satellite.path = lib.mkDefault (lib.getExe pkgs.xwayland-satellite-unstable);
        };
        noctalia = noctalia.nixosModules.default;
        quadlet = quadlet-nix.nixosModules.quadlet;
        sops = sops-nix.nixosModules.sops;

        helper = {
          # Add NUR substituters
          nix.settings = nixConfig;
          # Add custom packages
          nixpkgs.overlays = [
            self.overlays.external
          ];
        };

        default = { ... }: {
          imports = [
            self.nixosModules.helper
          ];

          nixpkgs.overlays = [
            self.overlays.default
          ];
        };
      };

      homeModules = with inputs; {
        dms = { ... }: {
          imports = with dms.homeModules; [
            dank-material-shell
            niri
          ];
        };
        niri = { ... }: {
          imports = [
            niri-flake.homeModules.niri
          ];

          programs.niri.package = pkgs.niri-unstable;
          programs.niri.settings.xwayland-satellite.path = lib.mkDefault (lib.getExe pkgs.xwayland-satellite-unstable);
        };
        noctalia = noctalia.homeModules.default;
        quadlet = quadlet-nix.homeManagerModule.quadlet;
        sops = sops-nix.homeManagerModule;
      };

      lib = inputs.nix-std.lib;
    };

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
      "https://a1ca7raz-nur.cachix.org"
    ];

    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      "a1ca7raz-nur.cachix.org-1:twTlSh62806B8lfG0QQzge4l5srn9Z8/xxyAFauOZnQ="
    ];
  };
}
