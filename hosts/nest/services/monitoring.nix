{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  dashboards = pkgs.linkFarm "grafana-dashboards" [
    {
      name = "node-exporter-full.json";
      path = pkgs.fetchurl {
        url = "https://grafana.com/api/dashboards/1860/revisions/latest/download";
        hash = "sha256-GExrdAnzBtp1Ul13cvcZRbEM6iOtFrXXjEaY6g6lGYY=";
      };
    }
    {
      name = "blocky.json";
      path = pkgs.writeText "blocky.json" (
        builtins.toJSON {
          uid = "nest-blocky";
          title = "Blocky";
          tags = [
            "nest"
            "dns"
          ];
          timezone = "browser";
          schemaVersion = 41;
          version = 1;
          refresh = "30s";
          time = {
            from = "now-6h";
            to = "now";
          };
          panels = [
            {
              id = 1;
              type = "stat";
              title = "Blocking";
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              gridPos = {
                h = 4;
                w = 6;
                x = 0;
                y = 0;
              };
              targets = [
                {
                  refId = "A";
                  expr = "blocky_blocking_enabled";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus";
                  };
                }
              ];
              fieldConfig = {
                defaults = {
                  mappings = [
                    {
                      type = "value";
                      options = {
                        "0".text = "Off";
                        "1".text = "On";
                      };
                    }
                  ];
                  thresholds = {
                    mode = "absolute";
                    steps = [
                      {
                        color = "red";
                        value = null;
                      }
                      {
                        color = "green";
                        value = 1;
                      }
                    ];
                  };
                };
                overrides = [ ];
              };
              options = {
                colorMode = "background";
                graphMode = "none";
                justifyMode = "center";
                reduceOptions = {
                  calcs = [ "lastNotNull" ];
                  fields = "";
                  values = false;
                };
                textMode = "value";
              };
            }
            {
              id = 2;
              type = "stat";
              title = "Cache entries";
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              gridPos = {
                h = 4;
                w = 6;
                x = 6;
                y = 0;
              };
              targets = [
                {
                  refId = "A";
                  expr = "blocky_cache_entries";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus";
                  };
                }
              ];
              fieldConfig = {
                defaults.unit = "short";
                overrides = [ ];
              };
              options = {
                colorMode = "value";
                graphMode = "area";
                justifyMode = "center";
                reduceOptions = {
                  calcs = [ "lastNotNull" ];
                  fields = "";
                  values = false;
                };
                textMode = "value";
              };
            }
            {
              id = 3;
              type = "timeseries";
              title = "Cache";
              datasource = {
                type = "prometheus";
                uid = "prometheus";
              };
              gridPos = {
                h = 8;
                w = 12;
                x = 0;
                y = 4;
              };
              targets = [
                {
                  refId = "A";
                  expr = "sum(rate(blocky_cache_hits_total[$__rate_interval]))";
                  legendFormat = "hits";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus";
                  };
                }
                {
                  refId = "B";
                  expr = "sum(rate(blocky_cache_misses_total[$__rate_interval]))";
                  legendFormat = "misses";
                  datasource = {
                    type = "prometheus";
                    uid = "prometheus";
                  };
                }
              ];
              fieldConfig = {
                defaults = {
                  color.mode = "palette-classic";
                  custom = {
                    drawStyle = "line";
                    fillOpacity = 10;
                    lineInterpolation = "linear";
                    lineWidth = 1;
                    pointSize = 5;
                    showPoints = "never";
                    spanNulls = false;
                  };
                  unit = "ops";
                };
                overrides = [ ];
              };
              options = {
                legend = {
                  calcs = [ ];
                  displayMode = "list";
                  placement = "bottom";
                  showLegend = true;
                };
                tooltip = {
                  mode = "multi";
                  sort = "none";
                };
              };
            }
          ];
        }
      );
    }
  ];
in
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
            enabledCollectors = [ "systemd" ];
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
                uid = "prometheus";
                access = "proxy";
                url = "http://127.0.0.1:9090";
                isDefault = true;
                editable = false;
              }
            ];
          };

          dashboards.settings = {
            apiVersion = 1;
            providers = [
              {
                name = "nest";
                type = "file";
                allowUiUpdates = false;
                disableDeletion = false;
                updateIntervalSeconds = 60;
                options.path = dashboards;
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
