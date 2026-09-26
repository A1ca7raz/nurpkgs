{
  inputs,
  pkgs
}:
let
  spicePkgs = inputs.spicetify.legacyPackages.${pkgs.system};
in
inputs.spicetify.lib.mkSpicetify pkgs {
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
