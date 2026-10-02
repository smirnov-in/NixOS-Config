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

Temporary remote access only passes the network restriction. Services that
also use Authelia still require an authorized LLDAP user.

## Identity

LLDAP is the user directory. Authelia authenticates users from LLDAP and is the
OIDC provider for services that support it.

The default rule is conservative:

- use Authelia/OIDC where the service supports it well;
- keep local service accounts where clients or admin flows need them;
- keep admin and daily user identities separate for user-facing services where
  multiple people have accounts;
- protect operator-only panels with the Authelia `admins` group instead of
  creating artificial non-admin users inside each panel;
- retain service-local credentials where APIs, service-to-service connections,
  or recovery flows require them;
- do not hide a local login until mobile, DAV, recovery, and admin workflows
  are known to work without it.

Administrative and daily identities are separate:

- `duck` and other regular users authenticate through SSO where the service
  supports it and do not receive service-local passwords;
- `duck-admin` is the personal administrative identity and may also have a
  service-local recovery password where the service can attach both methods to
  one account;
- the built-in LLDAP administrator is reserved for directory administration
  and recovery, not for normal application access.

## Services

| Service | Exposure | Identity source | Registration | Local login | Notes |
| --- | --- | --- | --- | --- | --- |
| Dashboard | LAN/remote CIDR only | Authelia | LLDAP users only | No | Main domain requires the `admins` group. |
| Authelia | Public | LLDAP | LLDAP users only | N/A | Authentication portal and OIDC provider. |
| LLDAP | LAN/remote CIDR only | Local LLDAP admin | Manual | Yes | Directory administration. |
| Immich | Public | Authelia OIDC | Auto-register enabled | Disabled normally | Password login is globally disabled. The local `duck-admin` credential remains dormant and can be enabled temporarily through the NixOS configuration for recovery. |
| Nextcloud | Public | Authelia OIDC plus local recovery for `duck-admin` | Auto-register enabled | Recovery only | Regular users are SSO-only. Local login for `duck-admin` stays available through `/login?noredir=1`. |
| Vaultwarden | Public | Vaultwarden local users | Manual | Yes | Intentionally independent from SSO; admin panel is LAN-only. |
| Jellyfin | Public | LLDAP via the Jellyfin LDAP plugin, plus a local recovery administrator | LDAP users are created on first login | Recovery only | Members of `service_users` authenticate with LLDAP credentials; members of both `service_users` and `admins`, such as `duck-admin`, receive Jellyfin administrator rights. The local recovery administrator remains independent. |
| Uptime Kuma | LAN/remote CIDR only | Uptime Kuma local users | Manual | Yes | Simple monitoring; no SSO currently. |
| Seerr | LAN/remote CIDR only | Jellyfin, backed by LLDAP for daily users | On first Jellyfin-backed login | Jellyfin credentials | Seerr delegates authentication to Jellyfin and runs through the Amnezia namespace for TMDB access. |
| qBittorrent | LAN/remote CIDR only | Authelia plus qBittorrent local credentials | LLDAP `admins`; local credentials are manual | API/recovery | Browser access requires `admins`; local credentials remain for Arr integration. Runs through Amnezia. |
| Prowlarr | LAN/remote CIDR only | Authelia plus Prowlarr local credentials | LLDAP `admins`; local credentials are manual | API/recovery | Browser access requires `admins`; local credentials remain for API access. Runs through Amnezia. |
| Sonarr | LAN/remote CIDR only | Authelia plus Sonarr local credentials | LLDAP `admins`; local credentials are manual | API/recovery | Browser access requires `admins`; local credentials remain for API access. Runs through Amnezia. |
| Radarr | LAN/remote CIDR only | Authelia plus Radarr local credentials | LLDAP `admins`; local credentials are manual | API/recovery | Browser access requires `admins`; local credentials remain for API access. Runs through Amnezia. |
| Bazarr | LAN/remote CIDR only | Authelia plus Bazarr local credentials | LLDAP `admins`; local credentials are manual | API/recovery | Browser access requires `admins`; local credentials remain for API access. Runs through Amnezia. |
| Blocky | LAN DNS only | N/A | N/A | N/A | DNS service; no user-facing auth. |

## Arr browser access

Caddy applies both `lan_only` and Authelia forward authentication to
qBittorrent, Prowlarr, Sonarr, Radarr, and Bazarr. The Authelia policy permits
only members of the LLDAP `admins` group.

This browser-level SSO does not replace application credentials. API keys and
qBittorrent credentials are still used for connections between Prowlarr,
Sonarr, Radarr, Seerr, and qBittorrent.

### Cloudflare-protected indexers

FlareSolverr runs alongside Prowlarr in the `amnezia` network namespace. Its
API listens only on `127.0.0.1:8191` inside that namespace; it has no Caddy
route or open firewall port. Both services use the same VPN egress.

Configure the integration in Prowlarr:

1. Open **Settings -> Indexer Proxies -> Add -> FlareSolverr**.
2. Set **Name** to `FlareSolverr`, **Host** to `http://127.0.0.1:8191`,
   **Request Timeout** to `60` seconds, and **Tags** to `rutracker`.
   Enable **Show Advanced** if the timeout field is hidden.
3. Test and save the proxy. It remains disabled until an indexer has the
   matching tag.
4. Edit RuTracker, choose `https://rutracker.org/` as **Base URL**, and add
   the same `rutracker` tag. Test and save the indexer.

Keep **Settings -> General -> Proxy** unchanged: FlareSolverr is an indexer
helper, not a general HTTP proxy. Prowlarr invokes it when it detects a
Cloudflare challenge. Passing the proxy test only verifies the integration;
the RuTracker test must pass separately, and not every challenge can be solved.

FlareSolverr logs at `warning` level because `info` and `debug` can include
request bodies containing indexer credentials. Do not enable verbose logging
while sending real credentials. Its runtime state is disposable; the proxy
configuration and indexer tags are stored in Prowlarr's database and covered
by Prowlarr's built-in backups.

After activation, check the service from `nest`:

```sh
systemctl is-active flaresolverr.service
sudo ip netns exec amnezia curl --noproxy '*' --fail --silent --show-error --max-time 10 http://127.0.0.1:8191/health
```

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

## Jellyfin LDAP

Jellyfin authentication uses the official LDAP Authentication plugin, installed
and configured through the Jellyfin web interface. The plugin binds to LLDAP as
the dedicated `jellyfin_bind` user, which belongs to `lldap_strict_readonly`.
Users allowed to sign in belong to `service_users` and are created in Jellyfin
on their first login. The LDAP administrator filter grants Jellyfin
administrator rights to members of the LLDAP `admins` group. Consequently,
`duck-admin` belongs to both `service_users` and `admins`, while ordinary users
belong only to `service_users`.

The local Jellyfin recovery administrator keeps the default authentication
provider and is reserved for recovery. Do not switch it to LDAP. The built-in
LLDAP `admin` remains directory-only and does not belong to `service_users`.
Seerr delegates its login to Jellyfin, so daily users use the same LLDAP
credentials there as well.

Jellyfin remains in the host network namespace so its public endpoint, LDAP
configuration, and Seerr integration keep their existing addresses. Its
outbound HTTP and HTTPS traffic uses Tinyproxy inside the `amnezia` namespace,
so TMDB metadata and artwork requests leave through the VPN. Loopback traffic
is excluded from the proxy for the local LDAP connection.

## Open questions

- Whether Seerr should become public after auth policy is settled.
- Whether `lan_only` should move from a fixed `192.168.1.0/24` to a declared
  home-network option after the LAN addressing plan is settled.
