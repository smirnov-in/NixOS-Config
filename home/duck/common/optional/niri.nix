{
  config,
  inputs,
  pkgs,
  ...
}: let
  noctalia = cmd:
    [
      "noctalia-shell"
      "ipc"
      "call"
    ]
    ++ (pkgs.lib.splitString " " cmd);
in {
  imports = [inputs.noctalia.homeModules.default];
  programs.niri.settings = {
    input = {
      keyboard.xkb = {
        layout = "us,ru";
        options = "shift:both_capslock_cancel,caps:escape,grp:win_space_toggle";
      };

      trackpoint = {
        accel-profile = "flat";
        accel-speed = 0.2;
      };
    };

    gestures = {
      hot-corners.enable = false;
    };

    prefer-no-csd = true;
    hotkey-overlay.skip-at-startup = true;

    layout = {
      shadow.enable = true;
      gaps = 12;
      focus-ring = {
        enable = true;
        active.color = "#cba6f7";
      };
    };

    window-rules = [
      {
        clip-to-geometry = true;
        geometry-corner-radius = {
          bottom-left = 20.0;
          bottom-right = 20.0;
          top-left = 20.0;
          top-right = 20.0;
        };
      }
    ];

    layer-rules = [
      {
        matches = [{namespace = "^noctalia-overview*";}];
        place-within-backdrop = true;
      }
    ];

    debug = {
      honor-xdg-activation-with-invalid-serial = [];
    };

    binds = with config.lib.niri.actions; {
      "Mod+Shift+Slash".action = show-hotkey-overlay;
      "Mod+Shift+E".action = quit;

      "Mod+T".action.spawn = "kitty";
      "Mod+B".action.spawn = "firefox";

      "Mod+H".action = focus-column-left;
      "Mod+J".action = focus-workspace-down;
      "Mod+K".action = focus-workspace-up;
      "Mod+L".action = focus-column-right;
      "Mod+U".action = focus-window-down;
      "Mod+I".action = focus-window-up;

      "Mod+Shift+H".action = move-column-left;
      "Mod+Shift+J".action = move-column-to-workspace-down;
      "Mod+Shift+K".action = move-column-to-workspace-up;
      "Mod+Shift+L".action = move-column-right;
      "Mod+Shift+U".action = move-window-down;
      "Mod+Shift+I".action = move-window-up;

      "Mod+BracketLeft".action = consume-or-expel-window-left;
      "Mod+BracketRight".action = consume-or-expel-window-right;
      "Mod+Comma".action = consume-window-into-column;
      "Mod+Period".action = expel-window-from-column;

      "Mod+O".action = toggle-overview;

      "Mod+R".action = switch-preset-column-width;
      "Mod+Shift+R".action = switch-preset-window-height;
      "Mod+Ctrl+R".action = reset-window-height;
      "Mod+F".action = maximize-column;
      "Mod+Shift+F".action = fullscreen-window;
      "Mod+Ctrl+F".action = expand-column-to-available-width;

      "Mod+C".action = center-column;
      "Mod+Shift+C".action = center-visible-columns;

      "Mod+Minus".action = set-column-width "-10%";
      "Mod+Equal".action = set-column-width "+10%";
      "Mod+Shift+Minus".action = set-window-height "-10%";
      "Mod+Shift+Equal".action = set-window-height "+10%";

      "Mod+G".action = toggle-window-floating;
      "Mod+Shift+G".action = switch-focus-between-floating-and-tiling;
      "Mod+Q".action = close-window;

      "Mod+D".action.spawn = noctalia "launcher toggle";

      "XF86AudioLowerVolume".action.spawn = noctalia "volume decrease";
      "XF86AudioRaiseVolume".action.spawn = noctalia "volume increase";
      "XF86AudioMicMute".action.spawn = noctalia "volume muteInput";

      "XF86AudioMute".action.spawn = noctalia "volume muteOutput";
      "XF86MonBrightnessDown".action.spawn = noctalia "brightness decrease";
      "XF86MonBrightnessUp".action.spawn = noctalia "brightness increase";

      "Print".action.screenshot = {};
      "Mod+Print".action.screenshot-screen = {};
      "Shift+Print".action.screenshot-window = {};
    };
  };

  programs.noctalia-shell = {
    enable = true;
    systemd.enable = true;
  };
}
