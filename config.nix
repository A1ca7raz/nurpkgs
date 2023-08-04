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
    pubkey = "test:eT4GHqLAtlnpFdngFYpI9i06OrlPjZDyHQ7wdoyEorw=";
  };
}
