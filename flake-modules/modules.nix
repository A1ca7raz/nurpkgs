{ lib, inputs, self, ... }:
let
  nixConfig = {
    extra-substituters = [
      "https://a1ca7raz-nur.cachix.org"
      "https://cache.numtide.com"
      "https://niri-nix.cachix.org"
    ];

    extra-trusted-public-keys = [
      "a1ca7raz-nur.cachix.org-1:twTlSh62806B8lfG0QQzge4l5srn9Z8/xxyAFauOZnQ="
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "niri-nix.cachix.org-1:SvFtqpDcf7Sm1SMJdby1/+Y+6f3Yt3/3PMcSTKPJNJ0="
    ];
  };
in {
  flake.nixosModules = with inputs; {
    colmena = colmena.nixosModules.deploymentOptions;
    disko = disko.nixosModules.disko;
    dms = { ... }: {
      imports = [
        dms.nixosModules.dank-material-shell
        dms-plugin-registry.nixosModules.default
      ];
    };
    # TODO: https://github.com/NousResearch/hermes-agent/blame/main/nix/nixosModules.nix
    # hermes = hermes-agent.nixosModules.default;
    home-manager = home-manager.nixosModules.home-manager;
    impermanence = impermanence.nixosModules.impermanence;
    lanzaboote = lanzaboote.nixosModules.lanzaboote;
    niri = { pkgs, lib, ... }: {
      imports = [
        niri-nix.nixosModules.default
      ];

      programs.niri.package = lib.mkDefault pkgs.niri-unstable;
    };
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
    dms = { ... }: {
      imports = [
        dms.homeModules.dank-material-shell
        dms-plugin-registry.homeModules.default
      ];
    };
    niri = { pkgs, ... }: {
      imports = [
        niri-nix.homeModules.default
      ];

      wayland.windowManager.niri.package = lib.mkDefault pkgs.niri-unstable;
      wayland.windowManager.niri.settings.xwayland-satellite.path = lib.mkDefault (lib.getExe pkgs.xwayland-satellite-unstable);
    };
    quadlet = quadlet-nix.homeManagerModule.quadlet;
    sops = sops-nix.homeManagerModule;
  };

  flake.lib = inputs.nix-std.lib;

  flake.overlays.default = final: prev:
    self.legacyPackages.x86_64-linux //
    self.packages.x86_64-linux;
}
