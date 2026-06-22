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

  environment.systemPackages = [ pkgs.amneziawg-tools ];
}
