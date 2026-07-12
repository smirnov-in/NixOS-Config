# Nest access notes

This file documents the intended access model for `nest`. It is operational
state, not a replacement for the NixOS modules.

## Network exposure

Public entry points:

- `80/tcp` and `443/tcp` are exposed for Caddy and ACME.
- SSH is exposed separately by router port forwarding.
- Service backends listen on loopback or private addresses and are reached
  through Caddy unless noted otherwise.

Caddy provides the shared `lan_only` snippet. A `lan_only` service allows
clients from `192.168.1.0/24` and temporary remote access CIDRs from
`NEST_REMOTE_ACCESS_CIDRS`; other clients get `403`.

## Identity

LLDAP is the user directory. Authelia authenticates users from LLDAP and is the
OIDC provider for services that support it.

The default rule is conservative:

- use Authelia/OIDC where the service supports it well;
- keep local service accounts where clients or admin flows need them;
- keep service admin accounts separate from ordinary user accounts;
- do not hide a local login until mobile, DAV, recovery, and admin workflows
  are known to work without it.

## Services

| Service | Exposure | Identity source | Registration | Local login | Notes |
| --- | --- | --- | --- | --- | --- |
| Dashboard | LAN/remote CIDR only | Authelia | LLDAP users only | No | Main domain requires the `admins` group. |
| Authelia | Public | LLDAP | LLDAP users only | N/A | Authentication portal and OIDC provider. |
| LLDAP | LAN/remote CIDR only | Local LLDAP admin | Manual | Yes | Directory administration. |
| Immich | Public | Authelia OIDC | Auto-register enabled | Disabled | Any Authelia user can create an Immich account on first login. |
| Nextcloud | Public | Authelia OIDC plus local users | Auto-register enabled | Enabled | Local login stays for admin, DAV/app-password, and recovery workflows. |
| Vaultwarden | Public | Vaultwarden local users | Manual | Yes | Admin panel is LAN-only. Revisit SSO later if Vaultwarden support is suitable. |
| Jellyfin | Public | Jellyfin local users | Manual | Yes | LDAP/SSO is intentionally undecided. Client compatibility matters here. |
| Uptime Kuma | LAN/remote CIDR only | Uptime Kuma local users | Manual | Yes | Simple monitoring; no SSO currently. |
| qBittorrent | LAN/remote CIDR only | qBittorrent local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Prowlarr | LAN/remote CIDR only | Prowlarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Sonarr | LAN/remote CIDR only | Sonarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Radarr | LAN/remote CIDR only | Radarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Bazarr | LAN/remote CIDR only | Bazarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Blocky | LAN DNS only | N/A | N/A | N/A | DNS service; no user-facing auth. |

## Open questions

- Whether Jellyfin should stay local-only for users or use LDAP/SSO.
- Whether Vaultwarden SSO is worth the complexity and recovery tradeoffs.
- Whether the Arr stack should remain locally authenticated or move behind
  Authelia for browser access.
- Whether Nextcloud password login can be hidden after DAV/mobile/recovery
  workflows are tested.
- Whether `lan_only` should move from a fixed `192.168.1.0/24` to a declared
  home-network option after the LAN addressing plan is settled.
