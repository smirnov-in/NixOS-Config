{ lib, options, ... }:
{
  config = lib.mkMerge [
    {
      services.uptime-kuma = {
        enable = true;
        settings = {
          HOST = "127.0.0.1";
          PORT = "3001";
        };
      };

      services.caddy.extraConfig = ''
        uptime.{$NEST_DOMAIN} {
          import lan_only
          reverse_proxy 127.0.0.1:3001
        }
      '';

      nest.dashboard.groups.services = [
        {
          Uptime = {
            href = "/uptime";
            description = "Health checks";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/uptime";
          target = "uptime";
        }
      ];
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/uptime-kuma"
      ];
    })
  ];
}
