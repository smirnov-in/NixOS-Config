{
  imports = [
    ../common/core

    ../common/gui/firefox.nix
    ../common/gui/flatpak.nix
    ../common/persistence/impermanence.nix
    ../common/gui/ghostty.nix
    ../common/gui/libreoffice.nix
    ../common/gui/mpv.nix
    ../common/cli/nix-index.nix
    ../common/gui/niri.nix
    ../common/gui/steam.nix
    ../common/gui/telegram.nix
    ../common/gui/transmission.nix
  ];

  home.stateVersion = "24.05";
}
