{
  imports = [
    ./hardware

    ../common/core

    ../common/persistence/impermanence.nix

    ../common/gui/niri.nix
    ../common/gui/steam.nix

    # ../common/services/amnezia.nix
    ../common/services/printing.nix

    ../common/security/yubikey.nix

    ../common/users/duck
  ];

  system.stateVersion = "24.05";
}
