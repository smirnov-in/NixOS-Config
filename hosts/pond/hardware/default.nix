{
  inputs,
  lib,
  options,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    ../../common/hardware/bluetooth.nix
    ../../common/hardware/laptop-power.nix

    inputs.disko.nixosModules.default
    (import ./disko.nix { device = "/dev/nvme0n1"; })

    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-amdgpu
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-nvidia
  ];

  config = lib.optionalAttrs (options.environment ? "persistence") {
    environment.persistence."/persist".directories = [
      "/etc/asusd"
    ];
  };
}
