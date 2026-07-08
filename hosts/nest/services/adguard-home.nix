{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  stateDir = "/var/lib/AdGuardHome";
  backupDir = "/srv/backups/adguard-home";
in
{
  config = lib.mkMerge [
    {
      services.adguardhome = {
        enable = true;
        host = "127.0.0.1";
        port = 8083;
        openFirewall = false;
        mutableSettings = true;

        settings = {
          dns = {
            bind_hosts = [
              "0.0.0.0"
            ];
            port = 53;
            upstream_dns = [
              "https://dns.quad9.net/dns-query"
              "https://dns10.quad9.net/dns-query"
            ];
            bootstrap_dns = [
              "9.9.9.9"
              "149.112.112.112"
            ];
          };

          filtering = {
            protection_enabled = true;
            filtering_enabled = true;
            safe_search.enabled = false;
          };

          filters = [
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
              name = "AdGuard DNS filter";
              id = 1;
            }
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
              name = "AdAway Default Blocklist";
              id = 2;
            }
          ];

          querylog = {
            enabled = true;
            interval = "2160h";
          };

          statistics = {
            enabled = true;
            interval = "2160h";
          };
        };
      };

      networking.firewall.interfaces.eno1 = {
        allowedTCPPorts = [ 53 ];
        allowedUDPPorts = [ 53 ];
      };

      nest.backups.local.jobs.adguard-home = {
        description = "Back up AdGuard Home state";
        after = [ "adguardhome.service" ];
        wants = [ "adguardhome.service" ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
        retention = {
          days = 14;
          pattern = "adguard-home-*.tar.zst";
        };
        script = ''
          umask 0077

          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/adguard-home-''${stamp}.tar.zst"
          archive_tmp="''${archive}.tmp"

          cleanup() {
            ${pkgs.coreutils}/bin/rm -f "$archive_tmp"
          }
          trap cleanup EXIT

          ${pkgs.gnutar}/bin/tar \
            --create \
            --directory ${stateDir} \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive_tmp" \
            .

          ${pkgs.coreutils}/bin/mv "$archive_tmp" "$archive"
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        backupDir
        stateDir
      ];
    })
  ];
}
