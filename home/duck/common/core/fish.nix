{
  config,
  lib,
  options,
  ...
}: {
  programs.fish = {
    enable = true;
  };

  home =
    {
      shell.enableFishIntegration = true;
    }
    // lib.optionalAttrs (options.home ? "persistence") {
      persistence = {
        "/persist/${config.home.homeDirectory}" = {
          files = [
            ".local/share/fish/fish_history"
          ];
        };
      };
    };
}
