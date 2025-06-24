{
  imports = [
    ./hardware

    ../common/core
    
    ../common/optional/gnome.nix
    
    ../common/users/duck
  ];

  system.stateVersion = "25.05";
}
