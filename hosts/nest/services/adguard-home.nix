{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.mkMerge [
    {
      services.adguardhome = {
        enable = true;
        host = "127.0.0.1";
        port = 8083;
        openFirewall = false;
        mutableSettings = true;

        settings = {
          dns = {
            bind_hosts = [
              "0.0.0.0"
            ];
            port = 53;
            upstream_dns = [
              "https://dns.quad9.net/dns-query"
              "https://dns10.quad9.net/dns-query"
            ];
            bootstrap_dns = [
              "9.9.9.9"
              "149.112.112.112"
            ];
          };

          filtering = {
            protection_enabled = true;
            filtering_enabled = true;
            safe_search.enabled = false;
          };

          filters = [
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
              name = "AdGuard DNS filter";
              id = 1;
            }
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
              name = "AdAway Default Blocklist";
              id = 2;
            }
          ];

          querylog = {
            enabled = true;
            interval = "2160h";
          };

          statistics = {
            enabled = true;
            interval = "2160h";
          };
        };
      };

      networking.firewall.interfaces.eno1 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/AdGuardHome"
      ];
    })
  ];
}
