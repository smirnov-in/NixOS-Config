{
  lib,
  options,
  ...
}: {
  programs.atuin = {
    enable = true;

    enableFishIntegration = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        directories = [
          ".local/share/atuin"
        ];
      };
    };
  };
}
