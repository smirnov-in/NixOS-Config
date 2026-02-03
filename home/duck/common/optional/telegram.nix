{
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
        "/persist" = {
          directories = [
            ".local/share/TelegramDesktop"
          ];
        };
      };
    };
}
