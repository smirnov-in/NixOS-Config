{ lib, options, ... }:
let
  mediaDirs = [
    "/srv/media"
    "/srv/media/movies"
    "/srv/media/music"
    "/srv/media/tv"
  ];
  downloadDirs = [
    "/srv/downloads"
    "/srv/downloads/complete"
    "/srv/downloads/incomplete"
    "/srv/downloads/watch"
  ];
in
{
  config = lib.mkMerge [
    {
      users.groups.media = { };

      users.users.duck.extraGroups = [ "media" ];

      systemd.tmpfiles.rules = [
        "d /srv/backups 0750 root root - -"
      ]
      ++ map (dir: "d ${dir} 2775 root media - -") (mediaDirs ++ downloadDirs);
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/srv/downloads"
        "/srv/media"
      ];
    })
  ];
}
