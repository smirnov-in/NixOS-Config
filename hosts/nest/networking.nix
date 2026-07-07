{
  networking = {
    useDHCP = false;
    useNetworkd = true;

    firewall = {
      enable = true;
      allowedTCPPorts = [ ];
      allowedUDPPorts = [ ];
    };
  };

  services.resolved.settings.Resolve.DNSStubListener = "no";

  systemd.network = {
    enable = true;

    networks."10-eno1" = {
      matchConfig.Name = "eno1";
      networkConfig.DHCP = "ipv4";
    };
  };
}
