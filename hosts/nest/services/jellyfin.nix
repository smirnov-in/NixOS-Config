{
  config,
  lib,
  options,
  pkgs,
  ...
}:
{
  config = lib.mkMerge [
    {
      services.jellyfin = {
        enable = true;
        openFirewall = false;
        hardwareAcceleration = {
          enable = true;
          device = "/dev/dri/renderD128";
          type = "qsv";
        };
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
        ];
      };

      users.users.jellyfin.extraGroups = [
        "media"
        "render"
        "video"
      ];

      services.caddy.extraConfig = ''
        jellyfin.{$NEST_DOMAIN} {
          reverse_proxy 127.0.0.1:8096
        }
      '';

      nest.dashboard.groups.services = [
        {
          Jellyfin = {
            href = "/jellyfin";
            description = "Media";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/jellyfin";
          target = "jellyfin";
        }
      ];
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/cache/jellyfin"
        "/var/lib/jellyfin"
      ];
    })
  ];
}
