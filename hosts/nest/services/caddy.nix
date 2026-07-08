{
  config,
  lib,
  options,
  ...
}:
let
  amneziaAddress = config.duck.vpn.amnezia.instances.amnezia.namespaceAddress;
in
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
          (lan_only) {
            @not_lan not remote_ip 192.168.1.0/24

            handle @not_lan {
              respond 403
            }
          }

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

          immich.{$NEST_DOMAIN} {
            reverse_proxy 127.0.0.1:2283
          }

          nextcloud.{$NEST_DOMAIN} {
            reverse_proxy 127.0.0.1:8081
          }

          qbit.{$NEST_DOMAIN} {
            import lan_only
            reverse_proxy ${amneziaAddress}:8080
          }

          prowlarr.{$NEST_DOMAIN} {
            import lan_only
            reverse_proxy ${amneziaAddress}:9696
          }

          sonarr.{$NEST_DOMAIN} {
            import lan_only
            reverse_proxy ${amneziaAddress}:8989
          }

          radarr.{$NEST_DOMAIN} {
            import lan_only
            reverse_proxy ${amneziaAddress}:7878
          }

          bazarr.{$NEST_DOMAIN} {
            import lan_only
            reverse_proxy ${amneziaAddress}:6767
          }

          dashboard.{$NEST_DOMAIN} {
            import lan_only

            handle /vault {
              redir https://vault.{$NEST_DOMAIN}
            }

            handle /nextcloud {
              redir https://nextcloud.{$NEST_DOMAIN}
            }

            handle /jellyfin {
              redir https://jellyfin.{$NEST_DOMAIN}
            }

            handle /immich {
              redir https://immich.{$NEST_DOMAIN}
            }

            handle /qbit {
              redir https://qbit.{$NEST_DOMAIN}
            }

            handle /prowlarr {
              redir https://prowlarr.{$NEST_DOMAIN}
            }

            handle /sonarr {
              redir https://sonarr.{$NEST_DOMAIN}
            }

            handle /radarr {
              redir https://radarr.{$NEST_DOMAIN}
            }

            handle /bazarr {
              redir https://bazarr.{$NEST_DOMAIN}
            }

            handle {
              reverse_proxy 127.0.0.1:8082 {
                header_up Host localhost:8082
              }
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
