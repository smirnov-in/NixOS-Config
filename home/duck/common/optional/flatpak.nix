{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  services.flatpak = {
    update = {
      onActivation = true;

      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };
  };

  home =
    {
      packages = with pkgs; [flatpak];
    }
    // lib.optionalAttrs (options.home ? "persistence") {
      persistence = {
        "/persist/${config.home.homeDirectory}" = {
          directories = [
            ".local/share/flatpak"
            ".var/app"
          ];
        };
      };
    };
}
