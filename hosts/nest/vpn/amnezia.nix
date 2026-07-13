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
      "172.29.172.254"
      "9.9.9.9"
      "149.112.112.112"
    ];
  };
}
