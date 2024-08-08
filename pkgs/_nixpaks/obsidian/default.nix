{ sloth, pkgs, config, ... }: {
  app.package = pkgs.obsidian;

  imports = [
    ../_modules/desktop.nix
    ../_modules/network.nix
  ];

  flatpak.appId = "md.obsidian.Obsidian";
}
# https://github.com/flathub/md.obsidian.Obsidian/blob/master/md.obsidian.Obsidian.yml
# https://github.com/flathub/md.obsidian.Obsidian/blob/master/obsidian.sh
