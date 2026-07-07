{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.mkMerge [
    {
      sops.secrets = {
        "nest/domain" = { };
        "nest/acme-email" = { };
      };

      sops.templates."caddy.env" = {
        owner = config.services.caddy.user;
        group = config.services.caddy.group;
        mode = "0400";
        content = ''
          NEST_DOMAIN=${config.sops.placeholder."nest/domain"}
          ACME_EMAIL=${config.sops.placeholder."nest/acme-email"}
        '';
      };

      services.caddy = {
        enable = true;
        email = "{$ACME_EMAIL}";
        environmentFile = config.sops.templates."caddy.env".path;
        openFirewall = true;

        extraConfig = ''
          {$NEST_DOMAIN} {
            respond "nest is ready"
          }

          vault.{$NEST_DOMAIN} {
            @admin path /admin*
            @not_lan not remote_ip 192.168.1.0/24

            handle @admin {
              respond @not_lan 403
              reverse_proxy 127.0.0.1:8222
            }

            handle {
              reverse_proxy 127.0.0.1:8222
            }
          }

          jellyfin.{$NEST_DOMAIN} {
            reverse_proxy 127.0.0.1:8096
          }

          nextcloud.{$NEST_DOMAIN} {
            reverse_proxy 127.0.0.1:8081
          }
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/caddy"
      ];
    })
  ];
}
