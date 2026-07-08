{
  config,
  lib,
  options,
  pkgs,
  ...
}:
let
  dataDir = "/var/lib/vaultwarden";
  backupDir = "/srv/backups/vaultwarden";
in
{
  config = lib.mkMerge [
    {
      sops.secrets."nest/vaultwarden/admin-token" = {
        owner = "vaultwarden";
        group = "vaultwarden";
      };

      sops.templates."vaultwarden.env" = {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
        content = ''
          DOMAIN=https://vault.${config.sops.placeholder."nest/domain"}
          ADMIN_TOKEN=${config.sops.placeholder."nest/vaultwarden/admin-token"}
        '';
      };

      services.vaultwarden = {
        enable = true;
        environmentFile = [ config.sops.templates."vaultwarden.env".path ];
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          SIGNUPS_ALLOWED = false;
          INVITATIONS_ALLOWED = true;
          WEBSOCKET_ENABLED = true;
        };
      };

      nest.backups.local.jobs.vaultwarden = {
        description = "Back up Vaultwarden state";
        after = [ "vaultwarden.service" ];
        inherit backupDir;
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "30m";
        };
        retention = {
          days = 14;
          pattern = "vaultwarden-*.tar.zst";
        };
        script = ''
          stamp="$(${pkgs.coreutils}/bin/date --utc +%Y%m%dT%H%M%SZ)"
          archive="${backupDir}/vaultwarden-''${stamp}.tar.zst"

          ${pkgs.systemd}/bin/systemctl stop vaultwarden.service
          trap '${pkgs.systemd}/bin/systemctl start vaultwarden.service' EXIT

          ${pkgs.gnutar}/bin/tar \
            --create \
            --directory ${dataDir} \
            --use-compress-program '${pkgs.zstd}/bin/zstd -T0' \
            --file "$archive" \
            .
        '';
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        backupDir
        "/var/lib/vaultwarden"
      ];
    })
  ];
}
