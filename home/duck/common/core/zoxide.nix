{
  lib,
  options,
  ...
}: {
  programs.zoxide = {
    enable = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        directories = [
          ".local/share/zoxide"
        ];
      };
    };
  };
}
