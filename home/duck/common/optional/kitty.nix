{pkgs, ...}: {
  programs.kitty = {
    enable = true;

    font = {
      name = "JetBrains Mono";
      package = pkgs.jetbrains-mono;
    };

    shellIntegration.enableFishIntegration = true;
  };

  home.packages = [pkgs.jetbrains-mono];
}
