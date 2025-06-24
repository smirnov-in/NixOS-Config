{pkgs, ...}: {
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
    };

    settings = {
      # background_opacity = 0.8;
      # hide_window_decorations = "yes";
    };

    shellIntegration.enableFishIntegration = true;
  };
}
