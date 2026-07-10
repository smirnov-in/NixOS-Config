{
  lib,
  options,
  pkgs,
  ...
}:
let
  dataDir = "/var/lib/uptime-kuma";
  backupDir = "/srv/backups/uptime-kuma";
in
{
  config = lib.mkMerge [
    {
      services.uptime-kuma = {
        enable = true;
        settings = {
          HOST = "127.0.0.1";
          PORT = "3001";
        };
      };

      services.caddy.extraConfig = ''
        uptime.{$NEST_DOMAIN} {
          import lan_only
          reverse_proxy 127.0.0.1:3001
        }
      '';

      nest.dashboard.groups.services = [
        {
          Uptime = {
            href = "/uptime";
            description = "Health checks";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/uptime";
          target = "uptime";
        }
      ];

      nest.backups.local.jobs.uptime-kuma = {
        description = "Back up Uptime Kuma state";
        after = [ "uptime-kuma.service" ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "uptime-kuma-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/uptime-kuma-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          uptime_kuma_was_active=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -f "$archive_tmp"
            if [ "$uptime_kuma_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start uptime-kuma.service || true
            fi
          }
          trap cleanup EXIT

          if ${pkgs.systemd}/bin/systemctl is-active --quiet uptime-kuma.service; then
            uptime_kuma_was_active=true
            ${pkgs.systemd}/bin/systemctl stop uptime-kuma.service
          fi

          ${pkgs.gnutar}/bin/tar \
            --create \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            --directory ${dataDir} \
            .

          ${pkgs.coreutils}/bin/mv "$archive_tmp" "$archive"
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        backupDir
        dataDir
      ];
    })
  ];
}
