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
            reverse_proxy 127.0.0.1:8222
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
