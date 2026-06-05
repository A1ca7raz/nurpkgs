{ lib, inputs, self, ... }:
let
  nixConfig = {
    extra-substituters = [
      "https://a1ca7raz-nur.cachix.org"
    ];

    extra-trusted-public-keys = [
      "a1ca7raz-nur.cachix.org-1:twTlSh62806B8lfG0QQzge4l5srn9Z8/xxyAFauOZnQ="
    ];
  };
in {
  flake.nixosModules = with inputs; {
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

    default = { ... }: {
      nix.settings = nixConfig;

      nixpkgs.overlays = [
        self.overlays.default
      ];
    };
  };

  flake.homeModules = with inputs; {
    # dms = dms.homeModules.dank-material-shell;
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

  flake.lib = inputs.nix-std.lib;

  flake.overlays.default = final: prev:
    self.legacyPackages.x86_64-linux //
    self.packages.x86_64-linux;
}
