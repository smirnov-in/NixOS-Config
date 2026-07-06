{
  imports = [
    ./hardware

    ../common/core

    ../common/networking/networkmanager.nix

    ../common/users/duck
  ];

  system.stateVersion = "26.05";
}
