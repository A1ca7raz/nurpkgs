{
  description = "A1ca7raz's Nix User Repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    # Packages from other flakes
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, flake-utils, ... }:
    let
      lib = nixpkgs.lib;
      meta = import ./meta.nix;
      nur = import ./pkgs;
      utils = import ./lib lib;
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
        packages = (flake-utils.lib.filterPackages pkgs.system (nur.packages pkgs)) // {
          inherit (pkgs) steam steam-run wpsoffice cloudflare-warp spotify;
        } // inputs.sops-nix.packages.${system};
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

      nixosModule = self.nixosModules.default;
      nixosModules.default = { ... }: {
        imports = utils.importsDirs ./modules;
        nixpkgs.overlays = [ self.overlay ];
        nix.settings = {
          substituters = [ meta.cache ];
          trusted-public-keys = [ meta.pubkey ];
        };
      };
    };
}
