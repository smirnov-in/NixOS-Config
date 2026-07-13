{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nest.dns;
  domain = config.sops.placeholder."nest/domain";
  splitDnsNames =
    lib.optional cfg.splitDnsRoot domain ++ map (name: "${name}.${domain}") cfg.splitDnsSubdomains;
in
{
  options.nest.dns = {
    lanAddress = lib.mkOption {
      type = lib.types.str;
      default = "192.168.1.216";
    };

    splitDnsRoot = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    splitDnsSubdomains = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = {
    sops.secrets."nest/domain" = { };

    sops.templates."blocky-split-dns.hosts" = {
      mode = "0444";
      content = ''
        ${cfg.lanAddress} ${lib.concatStringsSep " " splitDnsNames}
      '';
    };

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

        hostsFile = {
          sources = [
            config.sops.templates."blocky-split-dns.hosts".path
          ];
          hostsTTL = "5m";
          loading = {
            refreshPeriod = "0m";
            strategy = "failOnError";
          };
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
  };
}
