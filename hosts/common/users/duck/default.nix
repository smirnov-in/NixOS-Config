{
  config,
  configLib,
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  sops.secrets = {
    "duck-password".neededForUsers = true;
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;

    users.duck = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.duck-password.path;
      extraGroups = [
        "networkmanager"
        "transmission"
        "wheel"
      ];
      openssh.authorizedKeys.keyFiles = [
        ./keys/id_karp.pub
        ./keys/id_pike.pub
      ];
    };
  };

  programs.fuse.userAllowOther = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs configLib; };

    users = {
      "duck" = import ../../../../home/duck/${config.networking.hostName};
    };
    backupFileExtension = "backup";
  };
}
