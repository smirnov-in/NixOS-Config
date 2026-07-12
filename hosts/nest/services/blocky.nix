{ pkgs, ... }:
{
  services.blocky = {
    enable = true;

    settings = {
      ports = {
        dns = 53;
      };

      upstreams = {
        strategy = "parallel_best";
        groups.default = [
          "https://dns.quad9.net/dns-query"
          "https://dns10.quad9.net/dns-query"
        ];
      };

      bootstrapDns = [
        "tcp+udp:9.9.9.9"
        "tcp+udp:149.112.112.112"
      ];

      conditional.mapping = {
        "lan" = "192.168.1.1";
        "1.168.192.in-addr.arpa" = "192.168.1.1";
      };

      blocking = {
        denylists.ads = [
          "${pkgs.stevenblack-blocklist}/hosts"
        ];
        clientGroupsBlock.default = [ "ads" ];
        blockType = "zeroIp";
        blockTTL = "1m";
        loading = {
          refreshPeriod = "4h";
          strategy = "failOnError";
        };
      };

      caching = {
        minTime = "5m";
        maxTime = "30m";
        prefetching = true;
        prefetchExpires = "2h";
        cacheTimeNegative = "30m";
      };

      log = {
        level = "info";
        format = "text";
        timestamp = true;
        privacy = false;
      };
    };
  };

  networking.firewall.interfaces.eno1 = {
    allowedTCPPorts = [ 53 ];
    allowedUDPPorts = [ 53 ];
  };
}
