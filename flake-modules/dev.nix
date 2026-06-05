{ ... }:
{
  perSystem = { pkgs, ... }: {
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
  };
}
