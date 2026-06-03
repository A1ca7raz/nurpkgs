{
  inputs,
  pkgs
}:
let
  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
in
inputs.spicetify-nix.lib.mkSpicetify pkgs {
  enable = true;
  theme = spicePkgs.themes.dribbblish;
  colorScheme = "nord-light";

  enabledExtensions = with spicePkgs.extensions; [
    volumePercentage
    copyToClipboard
    playNext

    shuffle
    skipOrPlayLikedSongs
  ];
  enabledCustomApps = with spicePkgs.apps; [
    lyricsPlus
  ];
}
