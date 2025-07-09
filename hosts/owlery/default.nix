{
  imports = [
    ./hardware

    ../common/core

    ../common/optional/cosmic.nix

    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
