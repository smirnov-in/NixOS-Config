{
  config,
  lib,
  options,
  ...
}: {
  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".local/share/Steam"
        ];
      };
    };
  };
}
