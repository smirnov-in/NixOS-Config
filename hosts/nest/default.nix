{
  imports = [
    ./hardware
    ./networking.nix
    ./security.nix
    ./services
    ./storage.nix
    ./vpn/amnezia.nix

    ../common/base.nix

    ../common/users/duck
  ];

  system.stateVersion = "26.05";
}
