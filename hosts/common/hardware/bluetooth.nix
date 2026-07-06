{ lib, options, ... }:
{
  config = lib.mkMerge [
    {
      hardware.bluetooth.enable = true;
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/bluetooth"
      ];
    })
  ];
}
