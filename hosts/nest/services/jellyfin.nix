{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  dataDir = "/var/lib/jellyfin";
  backupDir = "/srv/backups/jellyfin";
in
{
  config = lib.mkMerge [
    {
      services.jellyfin = {
        enable = true;
        openFirewall = false;
        hardwareAcceleration = {
          enable = true;
          device = "/dev/dri/renderD128";
          type = "qsv";
        };
      };

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
          vpl-gpu-rt
        ];
      };

      users.users.jellyfin.extraGroups = [
        "media"
        "render"
        "video"
      ];

      services.caddy.extraConfig = ''
        jellyfin.{$NEST_DOMAIN} {
          reverse_proxy 127.0.0.1:8096
        }
      '';

      nest.dns.splitDnsSubdomains = [ "jellyfin" ];

      duck.vpn.amnezia.instances.amnezia.hostAllowedTCPPorts = [ 8096 ];

      nest.dashboard.groups.services = [
        {
          Jellyfin = {
            href = "/jellyfin";
            description = "Media";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/jellyfin";
          target = "jellyfin";
        }
      ];

      nest.backups.local.jobs.jellyfin = {
        description = "Back up Jellyfin state";
        after = [ "jellyfin.service" ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "jellyfin-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/jellyfin-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          jellyfin_was_active=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -f "$archive_tmp"
            if [ "$jellyfin_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start jellyfin.service || true
            fi
          }
          trap cleanup EXIT

          if ${pkgs.systemd}/bin/systemctl is-active --quiet jellyfin.service; then
            jellyfin_was_active=true
            ${pkgs.systemd}/bin/systemctl stop jellyfin.service
          fi

          ${pkgs.gnutar}/bin/tar \
            --create \
            --exclude ./log \
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
        "/var/cache/jellyfin"
        dataDir
      ];
    })
  ];
}
