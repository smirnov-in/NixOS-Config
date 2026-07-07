{
  imports = [
    ./hardware
    ./networking.nix
    ./services

    ../common/base.nix

    ../common/users/duck
  ];

  system.stateVersion = "26.05";
}
