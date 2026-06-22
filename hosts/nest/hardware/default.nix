{
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ./disko.nix { device = "/dev/nvme0n1"; })
  ];
}
