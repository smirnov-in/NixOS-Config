{
  lib,
  options,
  ...
}: {
  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        directories = [
          ".local/share/Steam"
        ];
      };
    };
  };
}
