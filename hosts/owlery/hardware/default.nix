{
  inputs,
  config,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ./fingerprint-reader.nix

    ../../common/hardware/bluetooth.nix
    ../../common/hardware/laptop-power.nix

    inputs.disko.nixosModules.default
    (import ./disko.nix { device = "/dev/nvme0n1"; })

    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14
  ];
}
