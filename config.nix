{
  extraPackages = pkgs: {
    inherit (pkgs)
      steam
      steam-run
      wpsoffice
      cloudflare-warp
      spotify
      veracrypt;
  };

  substituters = [
    "https://cache.wtm.moe/test"
    "https://cache.garnix.io"
  ];
  trusted-public-keys = [
    "test:k65B9/sD+gF6JX+Ug8ZSzcIbJ/pwD6JpUS/c9sx0SWI="
    "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
  ];
}
