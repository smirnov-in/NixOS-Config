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
  backupDir = "/srv/backups/nextcloud";
  dbName = config.services.nextcloud.config.dbname;
  dbDump = "${config.services.postgresqlBackup.location}/${dbName}.sql.zstd";
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

      nest.backups.local.jobs.nextcloud = {
        description = "Back up Nextcloud state";
        after = [
          "nextcloud-setup.service"
          "postgresql.service"
        ];
        inherit backupDir;
        serviceConfig = {
          LoadCredential = [
            "secret_file:${config.sops.templates."nextcloud-secrets.json".path}"
          ];
        };
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "nextcloud-*.tar.zst";
        };
        script = ''
          umask 0077

          occ="${config.services.nextcloud.occ}/bin/nextcloud-occ"
          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/nextcloud-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          workdir="$(${pkgs.coreutils}/bin/mktemp -d "${backupDir}/.nextcloud-backup.XXXXXX")"
          loaded_credentials_dir="$CREDENTIALS_DIRECTORY"
          credentials_dir="$(${pkgs.coreutils}/bin/mktemp -d /run/nextcloud-backup-credentials.XXXXXX)"
          maintenance_enabled=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -rf "$workdir" "$archive_tmp" "$credentials_dir"
            if [ "$maintenance_enabled" = true ]; then
              "$occ" maintenance:mode --off || true
            fi
          }
          trap cleanup EXIT

          ${pkgs.coreutils}/bin/install \
            --directory \
            --mode 0700 \
            --owner nextcloud \
            --group nextcloud \
            "$credentials_dir"
          ${pkgs.coreutils}/bin/install \
            --mode 0400 \
            --owner nextcloud \
            --group nextcloud \
            "$loaded_credentials_dir/secret_file" \
            "$credentials_dir/secret_file"
          export CREDENTIALS_DIRECTORY="$credentials_dir"

          "$occ" status --exit-code
          "$occ" maintenance:mode --on
          maintenance_enabled=true

          ${pkgs.systemd}/bin/systemctl start postgresqlBackup-${dbName}.service
          ${pkgs.coreutils}/bin/install --mode 0400 ${dbDump} "$workdir/postgresql.sql.zstd"

          ${pkgs.gnutar}/bin/tar \
            --create \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            --directory "$workdir" \
            postgresql.sql.zstd \
            --directory ${dataDir} \
            .

          ${pkgs.coreutils}/bin/mv "$archive_tmp" "$archive"

          "$occ" maintenance:mode --off
          maintenance_enabled=false
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/srv/backups/nextcloud"
        "/srv/nextcloud"
      ];
    })
  ];
}
