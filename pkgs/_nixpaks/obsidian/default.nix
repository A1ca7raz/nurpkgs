{ sloth, pkgs, config, ... }: {
  app.package = pkgs.obsidian;
  flatpak.appId = "md.obsidian.Obsidian";

  bubblewrap = {
    bind.rw = [
      (sloth.concat' sloth.homeDir "/Documents")
      (sloth.env "XDG_RUNTIME_DIR")
    ];
    bind.ro = [
      (sloth.concat' sloth.homeDir "/Downloads")
    ];
  };
}
# https://github.com/flathub/md.obsidian.Obsidian/blob/master/md.obsidian.Obsidian.yml
# https://github.com/flathub/md.obsidian.Obsidian/blob/master/obsidian.sh
