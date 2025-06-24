{
  config,
  lib,
  options,
  ...
}: {
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      hide_env_diff = true;
    };
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".local/share/direnv"
        ];
      };
    };
  };
}
