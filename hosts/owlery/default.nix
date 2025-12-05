{
  imports = [
    ./hardware

    ../common/core

    ../common/optional/fingerprint.nix
    ../common/optional/niri.nix
    ../common/optional/steam.nix
    ../common/optional/transmission.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
