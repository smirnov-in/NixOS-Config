{ config, ... }:
{
  imports = [
    ../../common/networking/vpn/amnezia.nix
  ];

  sops.secrets."vpn/amnezia-conf" = {
    owner = "root";
    group = "root";
    mode = "0400";
  };

  duck.vpn.amnezia.instances.amnezia = {
    configFile = config.sops.secrets."vpn/amnezia-conf".path;
    externalInterface = "eno1";
    hostAddress = "10.77.0.1";
    namespaceAddress = "10.77.0.2";
    dns = [
      "100.64.0.1"
      "8.8.4.4"
    ];
  };
}
