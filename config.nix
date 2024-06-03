{
  extraPackages = pkgs: {
    inherit (pkgs)
      steam
      steam-run
      wpsoffice
      cloudflare-warp
      spotify
      tor-browser
      veracrypt
      unrar;
  };

  jetbrainsPackages = pkgs: {
    inherit (pkgs.jetbrains)
#       clion
      datagrip
#       idea-ultimate
#       pycharm-professional
    ;
  };

  substituters = [
#     "https://cache.wtm.moe/test"
    "https://cache.garnix.io"
    "https://a1ca7raz-nur.cachix.org"
  ];
  trusted-public-keys = [
#     "test:k65B9/sD+gF6JX+Ug8ZSzcIbJ/pwD6JpUS/c9sx0SWI="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    "a1ca7raz-nur.cachix.org-1:twTlSh62806B8lfG0QQzge4l5srn9Z8/xxyAFauOZnQ="
  ];
}
