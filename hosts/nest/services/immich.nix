{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  mediaLocation = "/srv/immich";
  backupDir = "/srv/backups/immich";
  dbName = config.services.immich.database.name;
  dbDump = "${config.services.postgresqlBackup.location}/${dbName}.sql.zstd";
in
{
  config = lib.mkMerge [
    {
      services.immich = {
        enable = true;
        host = "127.0.0.1";
        port = 2283;
        openFirewall = false;

        inherit mediaLocation;

        database = {
          enable = true;
          createDB = true;
          host = "/run/postgresql";
          name = "immich";
          user = "immich";
        };

        redis = {
          enable = true;
          port = 0;
        };

        machine-learning.enable = true;
        accelerationDevices = [ "/dev/dri/renderD128" ];
      };

      systemd.tmpfiles.rules = [
        "d ${mediaLocation} 0700 immich immich - -"
      ];

      nest.backups.local.jobs.immich = {
        description = "Back up Immich state";
        after = [
          "immich-server.service"
          "postgresql.target"
        ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "immich-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/immich-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          workdir="$(${pkgs.coreutils}/bin/mktemp -d "${backupDir}/.immich-backup.XXXXXX")"
          immich_was_active=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -rf "$workdir" "$archive_tmp"
            if [ "$immich_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start immich-server.service || true
            fi
          }
          trap cleanup EXIT

          if ${pkgs.systemd}/bin/systemctl is-active --quiet immich-server.service; then
            immich_was_active=true
            ${pkgs.systemd}/bin/systemctl stop immich-server.service
          fi

          ${pkgs.systemd}/bin/systemctl start postgresqlBackup-${dbName}.service
          ${pkgs.coreutils}/bin/install --mode 0400 ${dbDump} "$workdir/postgresql.sql.zstd"

          ${pkgs.gnutar}/bin/tar \
            --create \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            --directory "$workdir" \
            postgresql.sql.zstd \
            --directory ${mediaLocation} \
            .

          ${pkgs.coreutils}/bin/mv "$archive_tmp" "$archive"
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        backupDir
        mediaLocation
        "/var/cache/immich"
        "/var/lib/immich"
      ];
    })
  ];
}
