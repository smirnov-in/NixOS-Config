{
  config,
  lib,
  pkgs,
  ...
}:
{
  sops.secrets = {
    "duck-password".neededForUsers = true;
  };

  users = {
    mutableUsers = false;
    defaultUserShell = pkgs.fish;

    users.duck = {
      isNormalUser = true;
      hashedPasswordFile = config.sops.secrets.duck-password.path;
      extraGroups = [ "wheel" ] ++ lib.optional config.virtualisation.libvirtd.enable "libvirtd";
      openssh.authorizedKeys.keyFiles = [
        ./keys/id_karp.pub
        ./keys/id_pike.pub
      ];
    };
  };
}
