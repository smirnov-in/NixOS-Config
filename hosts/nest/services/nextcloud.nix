{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  hostName = "nextcloud.internal";
  dataDir = "/srv/nextcloud";
in
{
  config = lib.mkMerge [
    {
      sops.secrets."nest/nextcloud/admin-password" = {
        owner = "nextcloud";
        group = "nextcloud";
      };

      sops.templates."nextcloud-secrets.json" = {
        owner = "nextcloud";
        group = "nextcloud";
        mode = "0400";
        content = ''
          {
            "trusted_domains": [
              "nextcloud.${config.sops.placeholder."nest/domain"}"
            ],
            "overwrite.cli.url": "https://nextcloud.${config.sops.placeholder."nest/domain"}",
            "overwritehost": "nextcloud.${config.sops.placeholder."nest/domain"}"
          }
        '';
      };

      services.nextcloud = {
        enable = true;
        package = pkgs.nextcloud33;

        inherit hostName;
        home = dataDir;
        datadir = dataDir;
        https = true;

        database.createLocally = true;
        configureRedis = true;
        maxUploadSize = "16G";
        secretFile = config.sops.templates."nextcloud-secrets.json".path;

        config = {
          adminuser = "admin";
          adminpassFile = config.sops.secrets."nest/nextcloud/admin-password".path;
          dbtype = "pgsql";
        };

        settings = {
          log_type = "systemd";
          overwriteprotocol = "https";
          trusted_proxies = [ "127.0.0.1" ];
        };
      };

      services.nginx.virtualHosts.${hostName} = {
        default = true;
        listen = [
          {
            addr = "127.0.0.1";
            port = 8081;
          }
        ];
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/srv/nextcloud"
        "/var/lib/postgresql"
      ];
    })
  ];
}
