# Nest restore notes

Backups live under `/srv/backups`. They are local safety copies on the same
machine, not disaster recovery. Copy them off-host before replacing disks or
reinstalling the system.

Run restore commands as root on `nest`.

## PostgreSQL

Database dumps are managed by `services.postgresqlBackup`:

- `/srv/backups/postgresql/immich.sql.zstd`
- `/srv/backups/postgresql/nextcloud.sql.zstd`

Restore one database from a dump:

```sh
systemctl stop immich-server.service nextcloud-setup.service phpfpm-nextcloud.service nginx.service
# Drop or rename the existing database first if it already exists.
zstd -dc /srv/backups/postgresql/immich.sql.zstd | sudo -u postgres psql
zstd -dc /srv/backups/postgresql/nextcloud.sql.zstd | sudo -u postgres psql
systemctl start immich-server.service nginx.service phpfpm-nextcloud.service
```

The dumps are created with `pg_dump -C`, so they include `CREATE DATABASE`.
Drop or rename an existing broken database first if needed.

## Vaultwarden

```sh
systemctl stop vaultwarden.service
tar --use-compress-program zstd -xf /srv/backups/vaultwarden/vaultwarden-YYYYMMDDTHHMMSSZ.tar.zst -C /var/lib/vaultwarden
chown -R vaultwarden:vaultwarden /var/lib/vaultwarden
systemctl start vaultwarden.service
```

## Nextcloud

The Nextcloud archive contains `postgresql.sql.zstd` plus `/srv/nextcloud`
contents.

```sh
systemctl stop phpfpm-nextcloud.service nginx.service nextcloud-setup.service
workdir="$(mktemp -d)"
tar --use-compress-program zstd -xf /srv/backups/nextcloud/nextcloud-YYYYMMDDTHHMMSSZ.tar.zst -C "$workdir"
zstd -dc "$workdir/postgresql.sql.zstd" | sudo -u postgres psql
rsync -a --delete "$workdir"/ /srv/nextcloud/
rm -f /srv/nextcloud/postgresql.sql.zstd
chown -R nextcloud:nextcloud /srv/nextcloud
systemctl start nginx.service phpfpm-nextcloud.service
```

Drop or rename the existing `nextcloud` database before loading the dump if it
already exists.

## Immich

The Immich archive contains `postgresql.sql.zstd` plus `/srv/immich` contents.

```sh
systemctl stop immich-server.service
workdir="$(mktemp -d)"
tar --use-compress-program zstd -xf /srv/backups/immich/immich-YYYYMMDDTHHMMSSZ.tar.zst -C "$workdir"
zstd -dc "$workdir/postgresql.sql.zstd" | sudo -u postgres psql
rsync -a --delete "$workdir"/ /srv/immich/
rm -f /srv/immich/postgresql.sql.zstd
chown -R immich:immich /srv/immich
systemctl start immich-server.service
```

Drop or rename the existing `immich` database before loading the dump if it
already exists.

## Jellyfin

The Jellyfin archive contains `/var/lib/jellyfin` state without logs.

```sh
systemctl stop jellyfin.service
tar --use-compress-program zstd -xf /srv/backups/jellyfin/jellyfin-YYYYMMDDTHHMMSSZ.tar.zst -C /var/lib/jellyfin
chown -R jellyfin:jellyfin /var/lib/jellyfin
systemctl start jellyfin.service
```

Media files under `/srv/media` are not included.

## Arr stack

The Arr archive contains built-in backup zip files for Radarr, Sonarr, Prowlarr,
Bazarr, plus qBittorrent state.

Prefer restoring Radarr/Sonarr/Prowlarr/Bazarr from their WebUI backup import.
For qBittorrent:

```sh
systemctl stop qbittorrent.service
workdir="$(mktemp -d)"
tar --use-compress-program zstd -xf /srv/backups/arr/arr-YYYYMMDDTHHMMSSZ.tar.zst -C "$workdir"
rsync -a --delete "$workdir/var/lib/qbittorrent/" /var/lib/qbittorrent/
chown -R qbittorrent:media /var/lib/qbittorrent
systemctl start qbittorrent.service
```

Downloads under `/srv/downloads` and media under `/srv/media` are not included.

## Uptime Kuma

The Uptime Kuma archive contains monitors, status pages, users, and check
history from `/var/lib/uptime-kuma`.

```sh
systemctl stop uptime-kuma.service
workdir="$(mktemp -d)"
tar --use-compress-program zstd -xf /srv/backups/uptime-kuma/uptime-kuma-YYYYMMDDTHHMMSSZ.tar.zst -C "$workdir"
rsync -a --delete "$workdir"/ /var/lib/uptime-kuma/
rm -rf "$workdir"
systemctl start uptime-kuma.service
```

## Caddy and Blocky

Caddy ACME state is persisted in `/var/lib/caddy`, but not copied into a local
backup archive. On a fresh restore Caddy can reissue certificates.

Blocky has no local application state in the current configuration; DNS rules
are declarative.
