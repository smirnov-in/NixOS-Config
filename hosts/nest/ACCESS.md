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
- keep admin and daily user identities separate for user-facing services where
  multiple people have accounts;
- treat operator-only panels as administrative surfaces instead of creating
  artificial non-admin users inside each panel;
- do not hide a local login until mobile, DAV, recovery, and admin workflows
  are known to work without it.

## Services

| Service | Exposure | Identity source | Registration | Local login | Notes |
| --- | --- | --- | --- | --- | --- |
| Dashboard | LAN/remote CIDR only | Authelia | LLDAP users only | No | Main domain requires the `admins` group. |
| Authelia | Public | LLDAP | LLDAP users only | N/A | Authentication portal and OIDC provider. |
| LLDAP | LAN/remote CIDR only | Local LLDAP admin | Manual | Yes | Directory administration. |
| Immich | Public | Authelia OIDC | Auto-register enabled | Disabled | Any Authelia user can create an Immich account on first login. |
| Nextcloud | Public | Authelia OIDC plus local users | Auto-register enabled | Recovery only | SSO is the default login path; local login stays available through `/login?noredir=1`. |
| Vaultwarden | Public | Vaultwarden local users | Manual | Yes | Intentionally independent from SSO; admin panel is LAN-only. |
| Jellyfin | Public | Jellyfin local users | Manual | Yes | Kept local-auth for client compatibility and because LDAP plugin management is not declarative here yet. |
| Uptime Kuma | LAN/remote CIDR only | Uptime Kuma local users | Manual | Yes | Simple monitoring; no SSO currently. |
| Seerr | LAN/remote CIDR only | Seerr/Jellyfin local users | Manual | Yes | Request portal for media; runs through the Amnezia namespace for TMDB access. |
| qBittorrent | LAN/remote CIDR only | qBittorrent local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Prowlarr | LAN/remote CIDR only | Prowlarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Sonarr | LAN/remote CIDR only | Sonarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Radarr | LAN/remote CIDR only | Radarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Bazarr | LAN/remote CIDR only | Bazarr local users | Manual | Yes | Runs through the Amnezia namespace for outbound traffic. |
| Blocky | LAN DNS only | N/A | N/A | N/A | DNS service; no user-facing auth. |

## Seerr setup

Seerr is inside the `amnezia` network namespace because it talks to TMDB
directly. Caddy reaches Seerr through the namespace address
`10.77.0.2:5055`.

Use these internal addresses in Seerr:

- Jellyfin: `10.77.0.1:8096`, SSL disabled.
- Radarr: `127.0.0.1:7878`, SSL disabled.
- Sonarr: `127.0.0.1:8989`, SSL disabled.

The initial Jellyfin connection should use a dedicated Jellyfin administrator
account. Daily Jellyfin users do not need administrator rights for Seerr usage.

## Open questions

- Whether Jellyfin LDAP is worth packaging or managing as a manual plugin.
- Whether Seerr should become public after auth policy is settled.
- Whether the Arr stack should remain locally authenticated or move behind
  Authelia for browser access.
- Whether `lan_only` should move from a fixed `192.168.1.0/24` to a declared
  home-network option after the LAN addressing plan is settled.
