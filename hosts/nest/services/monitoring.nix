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
        "nest/grafana/admin-password" = {
          owner = "grafana";
          group = "grafana";
          mode = "0400";
        };
        "nest/grafana/secret-key" = {
          owner = "grafana";
          group = "grafana";
          mode = "0400";
        };
      };

      sops.templates."grafana.env" = {
        owner = "grafana";
        group = "grafana";
        mode = "0400";
        content = ''
          NEST_DOMAIN=${config.sops.placeholder."nest/domain"}
        '';
      };

      services.prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        port = 9090;
        retentionTime = "30d";

        exporters = {
          node = {
            enable = true;
            listenAddress = "127.0.0.1";
            openFirewall = false;
          };

          systemd = {
            enable = true;
            listenAddress = "127.0.0.1";
            openFirewall = false;
          };
        };

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              {
                targets = [ "127.0.0.1:9100" ];
              }
            ];
          }
          {
            job_name = "systemd";
            static_configs = [
              {
                targets = [ "127.0.0.1:9558" ];
              }
            ];
          }
        ];
      };

      services.grafana = {
        enable = true;
        openFirewall = false;

        settings = {
          analytics.reporting_enabled = false;

          security = {
            admin_user = "admin";
            admin_password = "$__file{${config.sops.secrets."nest/grafana/admin-password".path}}";
            secret_key = "$__file{${config.sops.secrets."nest/grafana/secret-key".path}}";
          };

          server = {
            domain = "grafana.$__env{NEST_DOMAIN}";
            http_addr = "127.0.0.1";
            http_port = 3000;
            root_url = "https://grafana.$__env{NEST_DOMAIN}/";
          };

          users.allow_sign_up = false;
        };

        provision = {
          enable = true;

          datasources.settings = {
            apiVersion = 1;
            prune = true;
            datasources = [
              {
                name = "Prometheus";
                type = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
                editable = false;
              }
            ];
          };
        };
      };

      systemd.services.grafana.serviceConfig.EnvironmentFile = config.sops.templates."grafana.env".path;

      services.caddy.extraConfig = ''
        grafana.{$NEST_DOMAIN} {
          import lan_only
          reverse_proxy 127.0.0.1:3000
        }
      '';

      nest.dashboard.groups.services = [
        {
          Grafana = {
            href = "/grafana";
            description = "Metrics";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/grafana";
          target = "grafana";
        }
      ];
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/grafana"
        "/var/lib/prometheus2"
      ];
    })
  ];
}
