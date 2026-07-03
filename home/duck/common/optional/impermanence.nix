{
  lib,
  options,
  ...
}:
{
  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence."/persist" = {
      directories = [
        "Documents"
        "Downloads"
        "Music"
        "Pictures"
        "Projects"
        "Videos"
      ];
    };
  };
}
