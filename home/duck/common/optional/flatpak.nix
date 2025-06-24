{
  config,
  inputs,
  lib,
  options,
  ...
}: {
  imports = [
    inputs.nix-flatpak.homeManagerModules.nix-flatpak
  ];

  # home.packages = with pkgs; [
  #   flatpak
  # ];

  services.flatpak = {
    uninstallUnmanaged = true;

    update = {
      onActivation = true;

      auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };

    overrides = {
      global.Environment = {
        XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
        GTK_THEME = "Adwaita:dark";
      };
    };
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          ".local/share/flatpak"
          # ".local/share/flatpak/app"
          # ".local/share/flatpak/exports/bin"
          # ".local/share/flatpak/exports/share/applications"
          # ".local/share/flatpak/runtime"
          ".var/app"
        ];
      };
    };
  };
}
