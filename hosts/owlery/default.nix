{
  imports = [
    ./hardware

    ../common/core

    ../common/networking/networkmanager.nix

    ../common/gui/niri.nix

    ../common/services/amnezia.nix
    ../common/services/localsend.nix
    ../common/services/printing.nix
    ../common/services/transmission.nix

    ../common/security/fingerprint.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
