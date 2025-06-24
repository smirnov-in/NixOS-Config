{
  inputs,
  config,
  ...
}: {
  imports = [
    ./hardware-configuration.nix

    inputs.disko.nixosModules.default
    (import ./disko.nix {device = "/dev/nvme0n1";})

    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-amdgpu
    inputs.nixos-hardware.nixosModules.asus-zephyrus-ga402x-nvidia
  ];

  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.beta;
}
