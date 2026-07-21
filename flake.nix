{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    # Basic flakes
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-lib.url = "github:NixOS/nixpkgs/nixos-unstable?dir=lib";
    systems.url = "github:nix-systems/default";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };
    nix-std.url = "github:chessai/nix-std";

    # Dependencies of 3rd-party flakes
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.flake-parts.follows = "flake-parts";
    };
    crane.url = "github:ipetkov/crane";
    flake-compat = {
      url = "github:NixOS/flake-compat";
      flake = false;
    };
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
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
      url = "github:A1ca7raz/DankMaterialShell";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-compat.follows = "flake-compat";
    };
    dms-plugin-registry = {
      url = "github:AvengeMedia/dms-plugin-registry";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {  # TODO: replaced by preservation
      url = "github:nix-community/impermanence";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.crane.follows = "crane";
      inputs.pre-commit.follows = "";
      inputs.rust-overlay.follows = "rust-overlay";
    };
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
      inputs.flake-parts.follows = "flake-parts";
      inputs.bun2nix.follows = "bun2nix";
    };
    niri-nix = {
      url = "git+https://codeberg.org/BANanaD3V/niri-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.hercules-ci-effects.follows = "";
    };
    preservation.url = "github:nix-community/preservation";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
      ];

      imports = [
        ./flake-modules/custom-packages.nix
        ./flake-modules/external-packages.nix
        ./flake-modules/modules.nix
        ./flake-modules/dev.nix
      ];
    };
}
