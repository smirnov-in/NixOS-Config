{
  lib,
  options,
  ...
}: {
  programs.nix-index = {
    enable = true;
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        directories = [
          ".cache/nix-index"
        ];
      };
    };
  };
}
