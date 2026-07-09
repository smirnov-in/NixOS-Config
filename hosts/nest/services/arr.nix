{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  backupDir = "/srv/backups/arr";
  arrStateDirs = [
    "/var/lib/bazarr"
    "/var/lib/private/prowlarr"
    "/var/lib/qbittorrent"
    "/var/lib/radarr"
    "/var/lib/sonarr"
  ];
  arrServices = [
    "bazarr"
    "prowlarr"
    "qbittorrent"
    "radarr"
    "sonarr"
  ];
  arrBackupDirs = [
    "/var/lib/bazarr/Backups"
    "/var/lib/bazarr/backup"
    "/var/lib/bazarr/backups"
    "/var/lib/prowlarr/Backups"
    "/var/lib/radarr/.config/Radarr/Backups"
    "/var/lib/sonarr/.config/NzbDrone/Backups"
  ];
in
{
  config = lib.mkMerge [
    {
      services.qbittorrent = {
        enable = true;
        group = "media";
        profileDir = "/var/lib/qbittorrent";
        webuiPort = 8080;
        torrentingPort = 51413;
        openFirewall = false;
        extraArgs = [ "--confirm-legal-notice" ];
      };

      services.prowlarr = {
        enable = true;
        openFirewall = false;
      };

      services.sonarr = {
        enable = true;
        openFirewall = false;
      };

      services.radarr = {
        enable = true;
        openFirewall = false;
      };

      services.bazarr = {
        enable = true;
        openFirewall = false;
      };

      users.users = {
        bazarr.extraGroups = [ "media" ];
        radarr.extraGroups = [ "media" ];
        sonarr.extraGroups = [ "media" ];
      };

      duck.vpn.amnezia.instances.amnezia.services = arrServices;

      systemd.services = {
        bazarr.serviceConfig.ReadWritePaths = [
          "/srv/downloads"
          "/srv/media"
        ];
        qbittorrent.serviceConfig.ReadWritePaths = [ "/srv/downloads" ];
        radarr.serviceConfig.ReadWritePaths = [
          "/srv/downloads"
          "/srv/media"
        ];
        sonarr.serviceConfig.ReadWritePaths = [
          "/srv/downloads"
          "/srv/media"
        ];
      };

      nest.backups.local.jobs.arr = {
        description = "Back up Arr stack state";
        after = [
          "bazarr.service"
          "prowlarr.service"
          "qbittorrent.service"
          "radarr.service"
          "sonarr.service"
        ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "arr-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/arr-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          workdir="$(${pkgs.coreutils}/bin/mktemp -d "${backupDir}/.arr-backup.XXXXXX")"
          qbittorrent_was_active=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -rf "$workdir" "$archive_tmp"
            if [ "$qbittorrent_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start qbittorrent.service || true
            fi
          }
          trap cleanup EXIT

          for path in ${lib.escapeShellArgs arrBackupDirs}; do
            if [ -e "$path" ]; then
              ${pkgs.coreutils}/bin/install -d "$workdir/$(${pkgs.coreutils}/bin/dirname "$path")"
              ${pkgs.coreutils}/bin/cp -a --parents "$path" "$workdir"
            fi
          done

          if ${pkgs.systemd}/bin/systemctl is-active --quiet qbittorrent.service; then
            qbittorrent_was_active=true
            ${pkgs.systemd}/bin/systemctl stop qbittorrent.service
          fi

          ${pkgs.coreutils}/bin/install -d "$workdir/var/lib"
          ${pkgs.coreutils}/bin/cp -a --parents /var/lib/qbittorrent "$workdir"

          ${pkgs.gnutar}/bin/tar \
            --create \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            --directory "$workdir" \
            .

          ${pkgs.coreutils}/bin/mv "$archive_tmp" "$archive"
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        backupDir
      ]
      ++ arrStateDirs;
    })
  ];
}
