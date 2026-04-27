{
  imports = [
    ../common/core

    ../common/optional/firefox.nix
    ../common/optional/flatpak.nix
    ../common/optional/impermanence.nix
    ../common/optional/ghostty.nix
    ../common/optional/libreoffice.nix
    ../common/optional/mpv.nix
    ../common/optional/nix-index.nix
    ../common/optional/niri.nix
    ../common/optional/steam.nix
    ../common/optional/telegram.nix
    ../common/optional/transmission.nix
  ];

  home.stateVersion = "24.05";
}
