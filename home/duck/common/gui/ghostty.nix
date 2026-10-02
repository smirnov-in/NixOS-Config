{ config, ... }:

let
  unit = "app-com.mitchellh.ghostty.service";
in
{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;

    settings = {
      quit-after-last-window-closed = false;
      window-decoration = "client";
      # font-family = "JetBrainsMono Nerd Font";
      font-feature = [
        "calt"
        "liga"
        "dlig"
      ];
    };
  };

  # Home Manager installs the upstream unit but does not enable session autostart.
  xdg.configFile."systemd/user/graphical-session.target.wants/${unit}".source =
    config.xdg.configFile."systemd/user/${unit}".source;

  home.sessionVariables = {
    TERMINAL = "ghostty";
  };
}
