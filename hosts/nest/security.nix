{ lib, options, ... }:
{
  config = lib.mkMerge [
    {
      services.fail2ban = {
        enable = true;
        bantime = "15m";
        maxretry = 5;
        ignoreIP = [ "192.168.1.0/24" ];

        bantime-increment = {
          enable = true;
          maxtime = "24h";
          rndtime = "30m";
        };
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/fail2ban"
      ];
    })
  ];
}
