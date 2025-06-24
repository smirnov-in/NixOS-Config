{lib, ...}: {
  dconf.settings = {
    "org/gnome/desktop/peripherals/mouse" = {
      speed = 0.7;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      tap-to-click = true;
    };

    "org/gnome/desktop/background" = {
      picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-l.jpg";
      picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/adwaita-d.jpg";
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      scaling-factor = lib.gvariant.mkUint32 2;
    };

    "org/gnome/desktop/session" = {
      idle-delay = lib.gvariant.mkUint32 900;
    };

    "org/gnome/desktop/input-sources" = {
      xkb-options = [
        "ctrl:nocaps"
        "grp:toggle"
      ];
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      edge-tiling = true;
    };

    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "codium.desktop"
        "kitty.desktop"
        "org.telegram.desktop.desktop"
        "org.gnome.Nautilus.desktop"
      ];

      welcome-dialog-last-shown-version = "999";

      disable-user-extensions = false;
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };
  };
}
