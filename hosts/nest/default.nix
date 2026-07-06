{
  imports = [
    ./hardware

    ../common/base.nix

    ../common/networking/networkmanager.nix

    ../common/users/duck
  ];

  system.stateVersion = "26.05";
}
