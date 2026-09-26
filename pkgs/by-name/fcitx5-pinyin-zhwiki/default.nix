let
  # Update scripts run from the repo root (same convention as
  # nix-update --flake); paths here are repo-relative.
  dir = "pkgs/by-name/fcitx5-pinyin-zhwiki";
in
{
  nurpkgs.packages.fcitx5-pinyin-zhwiki = ./package.nix;
  nurpkgs.updater.fcitx5-pinyin-zhwiki = {
    script = pkgs: pkgs.writeShellApplication {
      name = "update-fcitx5-pinyin-zhwiki";
      runtimeInputs = [ pkgs.nvfetcher ];
      text = ''
        nvfetcher -c ${dir}/nvfetcher.toml -o ${dir}/_sources
      '';
    };
  };
}
