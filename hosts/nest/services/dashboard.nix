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
                Immich = {
                  href = "/immich";
                  description = "Photos";
                };
              }
            ];
          }
          {
            Media = [
              {
                qBittorrent = {
                  href = "/qbit";
                  description = "Downloads";
                };
              }
              {
                Prowlarr = {
                  href = "/prowlarr";
                  description = "Indexers";
                };
              }
              {
                Sonarr = {
                  href = "/sonarr";
                  description = "TV";
                };
              }
              {
                Radarr = {
                  href = "/radarr";
                  description = "Movies";
                };
              }
              {
                Bazarr = {
                  href = "/bazarr";
                  description = "Subtitles";
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
