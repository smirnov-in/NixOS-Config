{
  imports = [
    ./hardware

    ../common/core

    ../common/optional/cosmic.nix
    ../common/optional/fingerprint.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
