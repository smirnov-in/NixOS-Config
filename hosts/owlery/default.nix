{
  imports = [
    ./hardware

    ../common/core

    ../common/optional/amnezia.nix
    ../common/optional/fingerprint.nix
    ../common/optional/niri.nix
    ../common/optional/printing.nix
    ../common/optional/transmission.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
