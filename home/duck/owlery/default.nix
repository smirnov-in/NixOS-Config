{
  imports = [
    ../common/core

    ../common/gui/firefox.nix
    ../common/gui/ghostty.nix
    ../common/gui/libreoffice.nix
    ../common/gui/mpv.nix
    ../common/gui/niri.nix
    ../common/services/openconnect.nix
    ../common/gui/telegram.nix
  ];

  home.stateVersion = "25.05";
}
