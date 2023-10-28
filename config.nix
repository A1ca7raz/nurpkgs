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

  meta = {
    cache = "https://cache.wtm.moe/test";
    pubkey = "test:k65B9/sD+gF6JX+Ug8ZSzcIbJ/pwD6JpUS/c9sx0SWI=";
  };
}
