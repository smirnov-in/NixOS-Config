{
  inputs,
  lib,
  pkgs,
  ...
}:
let
  noctalia =
    cmd:
    [
      "noctalia"
      "msg"
    ]
    ++ (lib.splitString " " cmd);
in
{
  imports = [
    ./gtk.nix
    (inputs.home-manager-niri + "/modules/services/window-managers/niri.nix")
    inputs.noctalia.homeModules.default
  ];

  home.packages = with pkgs; [
    wl-clipboard
  ];

  wayland.windowManager.niri = {
    enable = true;
    # Keep the package here so Home Manager validates the generated KDL.
    package = pkgs.niri;

    # The NixOS configuration owns the session, systemd units, portals, and XWayland.
    systemd.enable = false;
    portalPackage = null;
    xwaylandSatellitePackage = null;

    settings = {
      _children = [
        {
          output = {
            _args = [ "PNP(AOC) 24P1W1 UIRP1HA000231" ];
            transform = "normal";
            position._props = {
              x = 0;
              y = 0;
            };
          };
        }
        {
          output = {
            _args = [ "PNP(AOC) 24P1W1 RJWNBHA000278" ];
            transform = "normal";
            position._props = {
              x = 1920;
              y = 0;
            };
          };
        }
        {
          window-rule = {
            clip-to-geometry = true;
            geometry-corner-radius = [
              20.0
              20.0
              20.0
              20.0
            ];
          };
        }
        {
          layer-rule = {
            match._props.namespace = "^noctalia-overview*";
            place-within-backdrop = true;
          };
        }
      ];

      spawn-at-startup = [ "noctalia" ];
      screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

      input = {
        focus-follows-mouse._props.max-scroll-amount = "90%";

        keyboard = {
          repeat-delay = 600;
          repeat-rate = 25;
          track-layout = "global";
          xkb = {
            layout = "us,ru";
            model = "";
            options = "shift:both_capslock_cancel,caps:escape,grp:win_space_toggle";
            rules = "";
            variant = "";
          };
        };

        touchpad = {
          natural-scroll = { };
          tap = { };
        };

        trackpoint = {
          accel-profile = "flat";
          accel-speed = 0.2;
        };
      };

      clipboard.disable-primary = { };
      cursor = {
        xcursor-size = 24;
        xcursor-theme = "Adwaita";
      };
      gestures.hot-corners.off = { };
      prefer-no-csd = { };
      hotkey-overlay.skip-at-startup = { };

      layout = {
        border.off = { };
        center-focused-column = "never";
        default-column-width = { };
        gaps = 12;
        focus-ring = {
          active-color = "#cba6f7";
          width = 4;
        };
        shadow = {
          color = "#00000070";
          draw-behind-window = false;
          offset._props = {
            x = 0.0;
            y = 5.0;
          };
          on = { };
          softness = 30.0;
          spread = 5.0;
        };
        struts = {
          bottom = 0;
          left = 0;
          right = 0;
          top = 0;
        };
      };

      debug.honor-xdg-activation-with-invalid-serial = { };

      binds = {
        "Mod+Shift+Slash".show-hotkey-overlay = { };
        "Mod+Shift+E".quit = { };

        "Mod+T".spawn = [ "ghostty" ];
        "Mod+B".spawn = [ "firefox" ];

        "Mod+H".focus-column-left = { };
        "Mod+J".focus-workspace-down = { };
        "Mod+K".focus-workspace-up = { };
        "Mod+L".focus-column-right = { };
        "Mod+U".focus-window-down = { };
        "Mod+I".focus-window-up = { };

        "Mod+Shift+H".move-column-left = { };
        "Mod+Shift+J".move-column-to-workspace-down = { };
        "Mod+Shift+K".move-column-to-workspace-up = { };
        "Mod+Shift+L".move-column-right = { };
        "Mod+Shift+U".move-window-down = { };
        "Mod+Shift+I".move-window-up = { };

        "Mod+Ctrl+H".focus-monitor-left = { };
        "Mod+Ctrl+J".focus-monitor-down = { };
        "Mod+Ctrl+K".focus-monitor-up = { };
        "Mod+Ctrl+L".focus-monitor-right = { };

        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

        "Mod+BracketLeft".consume-or-expel-window-left = { };
        "Mod+BracketRight".consume-or-expel-window-right = { };
        "Mod+Comma".consume-window-into-column = { };
        "Mod+Period".expel-window-from-column = { };

        "Mod+O".toggle-overview = { };

        "Mod+R".switch-preset-column-width = { };
        "Mod+Shift+R".switch-preset-window-height = { };
        "Mod+Ctrl+R".reset-window-height = { };
        "Mod+F".maximize-column = { };
        "Mod+Shift+F".fullscreen-window = { };
        "Mod+Ctrl+F".expand-column-to-available-width = { };

        "Mod+C".center-column = { };
        "Mod+Shift+C".center-visible-columns = { };

        "Mod+Minus".set-column-width = [ "-10%" ];
        "Mod+Equal".set-column-width = [ "+10%" ];
        "Mod+Shift+Minus".set-window-height = [ "-10%" ];
        "Mod+Shift+Equal".set-window-height = [ "+10%" ];

        "Mod+G".toggle-window-floating = { };
        "Mod+Shift+G".switch-focus-between-floating-and-tiling = { };
        "Mod+Q".close-window = { };

        "Mod+D".spawn = noctalia "panel-toggle launcher";

        "XF86AudioMute".spawn = noctalia "volume-mute";
        "XF86AudioLowerVolume".spawn = noctalia "volume-down";
        "XF86AudioRaiseVolume".spawn = noctalia "volume-up";
        "XF86AudioMicMute".spawn = noctalia "mic-mute";

        "XF86MonBrightnessDown".spawn = noctalia "brightness-down";
        "XF86MonBrightnessUp".spawn = noctalia "brightness-up";

        "Print".screenshot = { };
        "Mod+Print".screenshot-screen = { };
        "Shift+Print".screenshot-window = { };
      };
    };
  };

  programs.noctalia = {
    enable = true;
  };
}
