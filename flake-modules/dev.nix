{ ... }:
{
  perSystem = { pkgs, ... }: {
    formatter = pkgs.nixpkgs-fmt;
    devShells.default = pkgs.mkShell {
      nativeBuildInputs = with pkgs; [
        nvfetcher
        nix-update
        nix-init
      ];
    };
  };
}
