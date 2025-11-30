{
  imports = [
    ./hardware

    ../common/core

    # ../common/optional/amnezia.nix
    ../common/optional/impermanence.nix
    ../common/optional/niri.nix
    ../common/optional/printing.nix
    ../common/optional/yubikey.nix

    ../common/users/duck
  ];

  system.stateVersion = "24.05";
}
