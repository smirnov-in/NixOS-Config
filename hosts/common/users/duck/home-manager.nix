{
  config,
  configLib,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
  ];

  home-manager = {
    useGlobalPkgs = true;
    extraSpecialArgs = { inherit inputs configLib; };

    users = {
      "duck" = import ../../../../home/duck/${config.networking.hostName};
    };
    backupFileExtension = "backup";
  };
}
