{
  config,
  lib,
  options,
  ...
}: {
  programs.zoxide = {
    enable = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".local/share/zoxide"
        ];
      };
    };
  };
}
