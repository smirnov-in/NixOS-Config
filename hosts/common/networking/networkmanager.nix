{
  lib,
  options,
  ...
}:
{
  config = lib.mkMerge [
    {
      networking = {
        networkmanager.enable = true;
        useDHCP = lib.mkDefault true;
      };

      users.users.duck.extraGroups = [ "networkmanager" ];
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/etc/NetworkManager/system-connections"
      ];
    })
  ];
}
