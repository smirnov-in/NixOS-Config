{ pkgs, ... }:
let
  stateDir = "/run/nest-remote-access";
  envFile = "${stateDir}/caddy.env";
  stateFile = "${stateDir}/state";

  nestRemoteAccess = pkgs.writeShellApplication {
    name = "nest-remote-access";

    runtimeInputs = [
      pkgs.coreutils
      pkgs.python3
      pkgs.systemd
    ];

    text = ''
      set -euo pipefail

      close_unit=nest-remote-access-close

      require_root() {
        if [ "$(id -u)" -ne 0 ]; then
          echo "Run as root." >&2
          exit 1
        fi
      }

      usage() {
        cat <<'EOF'
      Usage:
        nest-remote-access open <ip-or-host-cidr> <ttl>
        nest-remote-access close
        nest-remote-access status

      Examples:
        nest-remote-access open 95.25.10.123/32 2h
        nest-remote-access open 2001:db8::1234/128 30min
      EOF
      }

      validate_host_cidr() {
        python3 - "$1" <<'PY'
      import ipaddress
      import sys

      value = sys.argv[1]

      try:
          network = ipaddress.ip_network(value, strict=False)
      except ValueError as error:
          print(f"Invalid IP/CIDR: {error}", file=sys.stderr)
          sys.exit(1)

      if network.prefixlen != network.max_prefixlen:
          print("Only single-host CIDRs are allowed (/32 for IPv4, /128 for IPv6).", file=sys.stderr)
          sys.exit(1)

      print(network)
      PY
      }

      validate_ttl() {
        systemd-analyze timespan "$1" >/dev/null
      }

      reload_caddy() {
        systemctl reload caddy.service
      }

      write_access_state() {
        cidr="$1"
        ttl="$2"

        mkdir -p ${stateDir}
        chmod 0755 ${stateDir}

        {
          printf 'NEST_REMOTE_ACCESS_CIDRS=%s\n' "$cidr"
        } > ${envFile}
        chmod 0644 ${envFile}

        {
          printf 'cidr=%s\n' "$cidr"
          printf 'ttl=%s\n' "$ttl"
          printf 'opened_at=%s\n' "$(date --iso-8601=seconds)"
        } > ${stateFile}
        chmod 0644 ${stateFile}
      }

      clear_access_state() {
        rm -f ${envFile} ${stateFile}
      }

      cancel_timer() {
        systemctl stop "$close_unit.timer" "$close_unit.service" >/dev/null 2>&1 || true
        systemctl reset-failed "$close_unit.timer" "$close_unit.service" >/dev/null 2>&1 || true
      }

      schedule_close() {
        ttl="$1"
        systemd-run --quiet --unit="$close_unit" --on-active="$ttl" --collect \
          /run/current-system/sw/bin/nest-remote-access expire
      }

      rollback_open() {
        clear_access_state
        cancel_timer
        reload_caddy >/dev/null 2>&1 || true
      }

      open_access() {
        require_root

        if [ "$#" -ne 2 ]; then
          usage >&2
          exit 1
        fi

        cidr="$(validate_host_cidr "$1")"
        ttl="$2"

        validate_ttl "$ttl"
        write_access_state "$cidr" "$ttl"
        cancel_timer

        if ! schedule_close "$ttl"; then
          rollback_open
          exit 1
        fi

        if ! reload_caddy; then
          rollback_open
          exit 1
        fi

        echo "Opened Caddy LAN-only access for $cidr until timer expiry ($ttl)."
      }

      close_access() {
        require_root
        clear_access_state
        if ! reload_caddy; then
          echo "Failed to reload Caddy; remote access may still be active in the running Caddy config." >&2
          exit 1
        fi
        cancel_timer
        echo "Closed Caddy remote access."
      }

      expire_access() {
        require_root
        clear_access_state
        reload_caddy
      }

      show_status() {
        if [ -f ${stateFile} ]; then
          cat ${stateFile}
        else
          echo "closed"
        fi

        systemctl list-timers "$close_unit.timer" --no-pager 2>/dev/null || true
      }

      case "''${1:-}" in
        open)
          shift
          open_access "$@"
          ;;
        close)
          shift
          close_access "$@"
          ;;
        expire)
          shift
          expire_access "$@"
          ;;
        status)
          shift
          show_status "$@"
          ;;
        -h|--help|help|"")
          usage
          ;;
        *)
          usage >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  environment.systemPackages = [
    nestRemoteAccess
  ];

  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    "-${envFile}"
  ];
}
