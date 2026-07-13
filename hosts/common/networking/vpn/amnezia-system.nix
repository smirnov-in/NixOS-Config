{
  config,
  pkgs,
  ...
}:
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
    kernelModules = [ "amneziawg" ];
  };

  services.ivpn.enable = true;

  environment.systemPackages = [
    pkgs.amneziawg-tools
    pkgs.ivpn
  ];
}
