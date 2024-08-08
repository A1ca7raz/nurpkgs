# https://github.com/nixpak/pkgs/blob/master/pkgs/modules/gui-base.nix
{ config, lib, sloth, ... }:
let
  envSuffix = envKey: suffix: sloth.concat' (sloth.env envKey) suffix;
in {
  dbus = {
    enable = true;
    policies = {
      "${config.flatpak.appId}" = "own";
      "org.freedesktop.DBus" = "talk";
      "org.gtk.vfs.*" = "talk";
      "org.gtk.vfs" = "talk";
      "ca.desrt.dconf" = "talk";
      "org.freedesktop.portal.*" = "talk";
      "org.a11y.Bus" = "talk";
    };
  };

  gpu.enable = lib.mkDefault true;
  gpu.provider = "bundle";

  fonts.enable = true;

  bubblewrap = {
    network = lib.mkDefault false;

    sockets = {
      wayland = true;
      pipewire = true;
      pulse = true;
      x11 = true;
    };

    # locale.enable = true;
    env.LOCALE_ARCHIVE = "/run/current-system/sw/lib/locale/locale-archive";

    bind.rw = [
      # TODO: impl app.commonName
      [
        (sloth.mkdir (sloth.concat' sloth.homeDir "/.local/state/nixpak/${config.flatpak.appId}/config"))
        (sloth.concat' sloth.homeDir "/.config")
      ]
      [
        (sloth.mkdir (envSuffix "HOME" "/.cache/${config.flatpak.appId}"))
        sloth.xdgCacheHome
      ]

      (sloth.concat' sloth.xdgCacheHome "/fontconfig")
      (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")

      (envSuffix "XDG_RUNTIME_DIR" "/at-spi/bus")
      (envSuffix "XDG_RUNTIME_DIR" "/gvfsd")
      (envSuffix "XDG_RUNTIME_DIR" "/pulse")
      (envSuffix "XDG_RUNTIME_DIR" "/doc")
    ];

    bind.ro = [
      [
        (sloth.concat ["/etc/profiles/per-user/" (sloth.env "USER") "/share/icons"])
        (sloth.concat' sloth.homeDir "/.icons")
      ]
      [
        "/run/current-system/sw/share/icons"
        "/usr/share/icons"
      ]

      (envSuffix "XDG_RUNTIME_DIR" "/systemd")

      (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
      (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
      (sloth.concat' sloth.xdgConfigHome "/fontconfig")
      (sloth.concat' sloth.homeDir "/.local/share/fonts")

      "/run/current-system/sw/lib/locale/locale-archive"
    ];
  };
}
