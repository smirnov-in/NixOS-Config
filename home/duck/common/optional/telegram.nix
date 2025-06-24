{
  config,
  lib,
  options,
  pkgs,
  ...
}: {
  home =
    {
      packages = with pkgs; [
        telegram-desktop
      ];
    }
    // lib.optionalAttrs (options.home ? "persistence") {
      persistence = {
        "/persist/${config.home.homeDirectory}" = {
          directories = [
            ".local/share/TelegramDesktop"
          ];
        };
      };
    };
}
