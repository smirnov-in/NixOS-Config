{
  imports = [
    ./hardware

    ../common/base.nix

    ../common/networking/networkmanager.nix

    ../common/gui/catppuccin.nix
    ../common/gui/localsend.nix
    ../common/gui/niri.nix
    ../common/gui/plymouth.nix

    ../common/services/amnezia.nix
    ../common/services/printing.nix

    ../common/security/fingerprint.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
