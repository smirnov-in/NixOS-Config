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
      networkConfig = {
        DHCP = "ipv4";
        DNS = [
          "9.9.9.9"
          "149.112.112.112"
        ];
      };
      dhcpV4Config.UseDNS = false;
      dhcpV6Config.UseDNS = false;
      ipv6AcceptRAConfig = {
        DHCPv6Client = false;
        UseDNS = false;
      };
    };
  };
}
