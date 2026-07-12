{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  amneziaAddress = config.duck.vpn.amnezia.instances.amnezia.namespaceAddress;
  dataDir = "/var/lib/seerr";
  backupDir = "/srv/backups/seerr";
in
{
  config = lib.mkMerge [
    {
      services.seerr = {
        enable = true;
        port = 5055;
        openFirewall = false;
      };

      services.caddy.extraConfig = ''
        seerr.{$NEST_DOMAIN} {
          import lan_only
          reverse_proxy ${amneziaAddress}:5055
        }
      '';

      duck.vpn.amnezia.instances.amnezia.services = [ "seerr" ];

      nest.dashboard.groups.media = [
        {
          Seerr = {
            href = "/seerr";
            description = "Requests";
          };
        }
      ];

      nest.dashboard.redirects = [
        {
          path = "/seerr";
          target = "seerr";
        }
      ];

      nest.backups.local.jobs.seerr = {
        description = "Back up Seerr state";
        after = [ "seerr.service" ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "weekly";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
        retention = {
          days = 28;
          pattern = "seerr-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/seerr-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"
          seerr_was_active=false

          cleanup() {
            ${pkgs.coreutils}/bin/rm -f "$archive_tmp"
            if [ "$seerr_was_active" = true ]; then
              ${pkgs.systemd}/bin/systemctl start seerr.service || true
            fi
          }
          trap cleanup EXIT

          if ${pkgs.systemd}/bin/systemctl is-active --quiet seerr.service; then
            seerr_was_active=true
            ${pkgs.systemd}/bin/systemctl stop seerr.service
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
