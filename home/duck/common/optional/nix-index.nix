{
  config,
  lib,
  options,
  ...
}: {
  programs.nix-index = {
    enable = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".cache/nix-index"
        ];
      };
    };
  };
}
