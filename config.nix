{
  extraPackages = pkgs: {
    inherit (pkgs)
      cloudflare-warp
      obsidian
      spotify
      steam
      steam-run
      tor-browser
      wpsoffice
      unrar
      veracrypt
    ;
  };

  jetbrainsPackages = pkgs: {
    inherit (pkgs.jetbrains)
#       clion
      datagrip
#       idea-ultimate
#       pycharm-professional
    ;
  };
}
