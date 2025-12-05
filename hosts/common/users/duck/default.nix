{
  config,
  configLib,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  sops.secrets = {
    "duck-password".neededForUsers = true;
    "yubico/u2f_keys" = {
      owner = "duck";
      inherit (config.users.users.duck) group;
      path = "/home/duck/.config/Yubico/u2f_keys";
    };
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;

    users.duck = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.duck-password.path;
      extraGroups = ["networkmanager" "transmission" "wheel"];
      openssh.authorizedKeys.keyFiles = [./keys/id_pike.pub];
    };
  };

  programs.fuse.userAllowOther = true;

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = {inherit inputs configLib;};

    users = {
      "duck" = import ../../../../home/duck/${config.networking.hostName};
    };
    backupFileExtension = "backup";
  };
}
