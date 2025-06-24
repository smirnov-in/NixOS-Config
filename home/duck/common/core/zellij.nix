{
  config,
  lib,
  options,
  ...
}: {
  programs.zellij = {
    enable = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".cache/zellij"
        ];
      };
    };
  };
}
