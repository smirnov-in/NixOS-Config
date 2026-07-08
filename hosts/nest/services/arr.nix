{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  backupDir = "/srv/backups/arr";
  torrentPort = 51413;
  arrStateDirs = [
    "/var/lib/bazarr"
    "/var/lib/private/prowlarr"
    "/var/lib/qbittorrent"
    "/var/lib/radarr"
    "/var/lib/sonarr"
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
        torrentingPort = torrentPort;
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

      networking.firewall = {
        allowedTCPPorts = [ torrentPort ];
        allowedUDPPorts = [ torrentPort ];
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
          services=(bazarr prowlarr qbittorrent radarr sonarr)
          active_services=()

          cleanup() {
            ${pkgs.coreutils}/bin/rm -f "$archive_tmp"
            for service in "''${active_services[@]}"; do
              ${pkgs.systemd}/bin/systemctl start "$service.service" || true
            done
          }
          trap cleanup EXIT

          for service in "''${services[@]}"; do
            if ${pkgs.systemd}/bin/systemctl is-active --quiet "$service.service"; then
              active_services+=("$service")
              ${pkgs.systemd}/bin/systemctl stop "$service.service"
            fi
          done

          ${pkgs.gnutar}/bin/tar \
            --create \
            --ignore-failed-read \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            --directory /var/lib \
            bazarr \
            qbittorrent \
            radarr \
            sonarr \
            --directory /var/lib/private \
            prowlarr

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
