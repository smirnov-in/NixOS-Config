{config, ...}: {
  programs.niri.settings = {
    layout.shadow.enable = true;

    binds = with config.lib.niri.actions; {
      "Mod+D".action.spawn = "fuzzel";

      "Mod+H".action = focus-column-left;
      "Mod+L".action = focus-column-right;

      "Mod+Q".action = close-window;
    };
  };

  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";

        modules-left = ["niri/workspaces"];
        modules-center = ["clock"];
        modules-right = ["network"];
      };
    };

    systemd.enable = true;
  };

  programs.fuzzel = {
    enable = true;
  };
}
