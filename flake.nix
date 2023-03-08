{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    let
      lib = nixpkgs.lib;
      nur = import ./pkgs;
      meta = import ./meta.nix;
      system = [ "x86_64-linux" ];
    in
    flake-utils.lib.eachSystem system (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ self.overlays.default ];
        };
        inherit (pkgs) mkShell;
      in rec {
        packages = flake-utils.lib.filterPackages pkgs.system (nur.packages pkgs);
        checks = packages;
        formatter = pkgs.nixpkgs-fmt;
        devShells.default = mkShell { nativeBuildInputs = with pkgs; [ nvfetcher ]; };
        apps.update = {
          type = "app";
          program = (pkgs.writeShellScript "script" ''
            ${pkgs.nvfetcher}/bin/nvfetcher -c pkgs/nvfetcher.toml -o pkgs/_sources "$@"
          '').outPath;
        };
    }) // {
      overlay = self.overlays.default;
      overlays.default = nur.overlay;

      nixosModule = self.nixosModules.register;
      nixosModules.register = { ... }: {
        nixpkgs.overlays = [ self.overlay ];
        nix.settings = {
          substituters = [ meta.cache ];
          trusted-public-keys = [ meta.pubkey ];
        };
      };
    };
}
