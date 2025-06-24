{
  config,
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
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".local/share/atuin"
        ];
      };
    };
  };
}
