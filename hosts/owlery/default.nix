{
  imports = [
    ./hardware

    ../common/core

    ../common/services/amnezia.nix
    ../common/security/fingerprint.nix
    ../common/services/localsend.nix
    ../common/gui/niri.nix
    ../common/services/printing.nix
    ../common/services/transmission.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
