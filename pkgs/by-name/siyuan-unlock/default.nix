let
  # Update scripts run from the repo root (same convention as
  # nix-update --flake); paths here are repo-relative.
  dir = "pkgs/by-name/siyuan-unlock";
in
{
  nurpkgs.packages.siyuan-unlock = ./siyuan-unlock.nix;
  nurpkgs.packages.siyuan-headless = ./siyuan-headless.nix;
  nurpkgs.updater.siyuan-patch = {
    packages = [ "siyuan-unlock" "siyuan-headless" ];
    script = pkgs: pkgs.writeShellApplication {
      name = "update-siyuan-patch";
      runtimeInputs = [ pkgs.nvfetcher ];
      text = ''
        nvfetcher -c ${dir}/nvfetcher.toml -o ${dir}/_sources
      '';
    };
  };
}
