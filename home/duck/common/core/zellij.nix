{
  lib,
  options,
  ...
}: {
  programs.zellij = {
    enable = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        directories = [
          ".cache/zellij"
        ];
      };
    };
  };
}
