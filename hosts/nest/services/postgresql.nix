{ lib, options, ... }:
{
  config = lib.mkMerge [
    {
      services.postgresqlBackup = {
        enable = true;
        backupAll = false;
        location = "/srv/backups/postgresql";
        compression = "zstd";
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/srv/backups/postgresql"
        "/var/lib/postgresql"
      ];
    })
  ];
}
