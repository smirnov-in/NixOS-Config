{
  users.groups.media = { };

  users.users.duck.extraGroups = [ "media" ];

  systemd.tmpfiles.rules = [
    "d /srv/media 2775 root media - -"
    "d /srv/backups 0750 root root - -"
  ];
}
