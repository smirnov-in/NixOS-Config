{
  imports = [
    ./hardware

    ../common/core

    # ../common/services/amnezia.nix
    ../common/persistence/impermanence.nix
    ../common/gui/niri.nix
    ../common/services/printing.nix
    ../common/gui/steam.nix
    ../common/security/yubikey.nix

    ../common/users/duck
  ];

  system.stateVersion = "24.05";
}
