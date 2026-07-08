{
  lib,
  options,
  ...
}:
let
  mediaLocation = "/srv/immich";
in
{
  config = lib.mkMerge [
    {
      services.immich = {
        enable = true;
        host = "127.0.0.1";
        port = 2283;
        openFirewall = false;

        inherit mediaLocation;

        database = {
          enable = true;
          createDB = true;
          host = "/run/postgresql";
          name = "immich";
          user = "immich";
        };

        redis = {
          enable = true;
          port = 0;
        };

        machine-learning.enable = true;
        accelerationDevices = [ "/dev/dri/renderD128" ];
      };

      systemd.tmpfiles.rules = [
        "d ${mediaLocation} 0700 immich immich - -"
      ];
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        mediaLocation
        "/var/cache/immich"
        "/var/lib/immich"
      ];
    })
  ];
}
