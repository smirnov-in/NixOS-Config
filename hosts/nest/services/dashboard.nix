{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.mkMerge [
    {
      services.homepage-dashboard = {
        enable = true;
        listenPort = 8082;
        openFirewall = false;

        settings = {
          title = "Nest";
          headerStyle = "boxed";
          hideVersion = true;
          statusStyle = "dot";
        };

        widgets = [
          {
            resources = {
              cpu = true;
              memory = true;
              disk = "/";
            };
          }
          {
            datetime = {
              text_size = "xs";
              format = {
                dateStyle = "short";
                timeStyle = "short";
              };
            };
          }
        ];

        services = [
          {
            Services = [
              {
                Vaultwarden = {
                  href = "/vault";
                  description = "Passwords";
                };
              }
              {
                Nextcloud = {
                  href = "/nextcloud";
                  description = "Files";
                };
              }
              {
                Jellyfin = {
                  href = "/jellyfin";
                  description = "Media";
                };
              }
              {
                "AdGuard Home" = {
                  href = "/adguard";
                  description = "DNS";
                };
              }
            ];
          }
        ];
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/private/homepage-dashboard"
      ];
    })
  ];
}
