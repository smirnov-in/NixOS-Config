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

        extraConfig = lib.mkBefore ''
          (lan_only) {
            @not_lan not remote_ip 192.168.1.0/24 {$NEST_REMOTE_ACCESS_CIDRS:}

            handle @not_lan {
              respond 403
            }
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
