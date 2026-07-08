{
  imports = [
    ./hardware
    ./networking.nix
    ./services
    ./storage.nix
    ./vpn/amnezia.nix

    ../common/base.nix

    ../common/users/duck
  ];

  system.stateVersion = "26.05";
}
