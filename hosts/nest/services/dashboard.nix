{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.nest.dashboard;

  mkRedirect = route: ''
    handle ${route.path} {
      redir https://${route.target}.{$NEST_DOMAIN}
    }
  '';

  redirectsConfig = lib.concatMapStringsSep "\n" mkRedirect cfg.redirects;
in
{
  options.nest.dashboard = {
    groups = {
      services = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
      };

      media = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        default = [ ];
      };
    };

    redirects = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            path = lib.mkOption {
              type = lib.types.str;
            };

            target = lib.mkOption {
              type = lib.types.str;
            };
          };
        }
      );
      default = [ ];
    };
  };

  config = lib.mkMerge [
    {
      services.caddy.extraConfig = ''
        {$NEST_DOMAIN} {
          route {
            import lan_only
            import authelia_forward_auth

            ${redirectsConfig}

            handle {
              reverse_proxy 127.0.0.1:8082 {
                header_up Host localhost:8082
              }
            }
          }
        }

        dashboard.{$NEST_DOMAIN} {
          redir https://{$NEST_DOMAIN}{uri}
        }
      '';

      nest.dns = {
        splitDnsRoot = true;
        splitDnsSubdomains = [ "dashboard" ];
      };

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

        services =
          lib.optional (cfg.groups.services != [ ]) { Services = cfg.groups.services; }
          ++ lib.optional (cfg.groups.media != [ ]) { Media = cfg.groups.media; };
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/private/homepage-dashboard"
      ];
    })
  ];
}
