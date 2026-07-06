{
  inputs,
  ...
}:
{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./rollback-root.nix
    ./system-paths.nix
  ];
}
