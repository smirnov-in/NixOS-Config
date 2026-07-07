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
  users.groups.media = { };

  users.users.duck.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d /srv 0755 root root - -"
    "d /srv/backups 0750 root root - -"
  ]
  ++ map (dir: "d ${dir} 2775 root media - -") (mediaDirs ++ downloadDirs);
}
