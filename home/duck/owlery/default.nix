{
  imports = [
    ../common/core

    ../common/gui/catppuccin.nix
    ../common/gui/firefox.nix
    ../common/gui/ghostty.nix
    ../common/gui/libreoffice.nix
    ../common/gui/mpv.nix
    ../common/gui/niri.nix
    ../common/gui/telegram.nix

    ../common/services/openconnect.nix
  ];

  home.stateVersion = "25.05";
}
