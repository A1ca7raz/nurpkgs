{
  extraPackages = pkgs: {
    inherit (pkgs)
      obsidian
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
