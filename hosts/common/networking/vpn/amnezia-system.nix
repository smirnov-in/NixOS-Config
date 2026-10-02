{
  config,
  inputs,
  pkgs,
  ...
}:
let
  pkgsUnstable = import inputs.nixpkgs-unstable {
    inherit (pkgs.stdenv.hostPlatform) system;
    inherit (config.nixpkgs) config;
  };
in
{
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.amneziawg ];
    kernelModules = [ "amneziawg" ];
  };

  programs.amnezia-vpn = {
    enable = true;
    package = pkgsUnstable.amnezia-vpn;
  };

  environment.systemPackages = [ pkgs.amneziawg-tools ];
}
