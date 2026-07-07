{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nest.backups.local;
in
{
  options.nest.backups.local.jobs = lib.mkOption {
    type = lib.types.attrsOf (
      lib.types.submodule (
        { name, ... }:
        {
          options = {
            backupDir = lib.mkOption {
              type = lib.types.str;
            };

            description = lib.mkOption {
              type = lib.types.str;
              default = "Back up ${name}";
            };

            owner = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };

            group = lib.mkOption {
              type = lib.types.str;
              default = "root";
            };

            mode = lib.mkOption {
              type = lib.types.str;
              default = "0750";
            };

            after = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            wants = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [ ];
            };

            serviceConfig = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = { };
            };

            timerConfig = lib.mkOption {
              type = lib.types.attrsOf lib.types.anything;
              default = {
                OnCalendar = "daily";
                Persistent = true;
                RandomizedDelaySec = "30m";
              };
            };

            retention = {
              pattern = lib.mkOption {
                type = lib.types.str;
                default = "${name}-*.tar.zst";
              };

              days = lib.mkOption {
                type = lib.types.nullOr lib.types.ints.positive;
                default = 14;
              };
            };

            script = lib.mkOption {
              type = lib.types.lines;
            };
          };
        }
      )
    );
    default = { };
  };

  config = {
    systemd.tmpfiles.rules = lib.mapAttrsToList (
      _: job: "d ${job.backupDir} ${job.mode} ${job.owner} ${job.group} - -"
    ) cfg.jobs;

    systemd.services = lib.mapAttrs' (
      name: job:
      lib.nameValuePair "${name}-backup" {
        inherit (job) after description wants;
        serviceConfig = {
          Type = "oneshot";
          ExecStart = pkgs.writeShellScript "${name}-backup" ''
            set -euo pipefail

            ${job.script}

            ${lib.optionalString (job.retention.days != null) ''
              ${pkgs.findutils}/bin/find ${job.backupDir} \
                -maxdepth 1 \
                -name '${job.retention.pattern}' \
                -type f \
                -mtime +${toString job.retention.days} \
                -delete
            ''}
          '';
        }
        // job.serviceConfig;
      }
    ) cfg.jobs;

    systemd.timers = lib.mapAttrs' (
      name: job:
      lib.nameValuePair "${name}-backup" {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          Unit = "${name}-backup.service";
        }
        // job.timerConfig;
      }
    ) cfg.jobs;
  };
}
