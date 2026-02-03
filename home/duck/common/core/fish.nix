{
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
        "/persist" = {
          files = [
            {
              file = ".local/share/fish/fish_history";
              method = "symlink";
            }
          ];
        };
      };
    };
}
