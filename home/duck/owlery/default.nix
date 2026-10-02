{
  imports = [
    ../common/base.nix

    ../common/cli/elan.nix

    ../common/gui/catppuccin.nix
    ../common/gui/firefox.nix
    ../common/gui/ghostty.nix
    ../common/gui/libreoffice.nix
    ../common/gui/mpv.nix
    ../common/gui/niri.nix
    ../common/gui/obs.nix
    ../common/gui/telegram.nix
    ../common/gui/vscode.nix
    ../common/gui/wl-mirror.nix

    ../common/services/openconnect.nix
  ];

  home.stateVersion = "25.05";
}
