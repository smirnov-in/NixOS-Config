{
  config,
  lib,
  options,
  ...
}:
{
  config = lib.mkMerge [
    {
      sops.secrets."nest/vaultwarden/admin-token" = {
        owner = "vaultwarden";
        group = "vaultwarden";
      };

      sops.templates."vaultwarden.env" = {
        owner = "vaultwarden";
        group = "vaultwarden";
        mode = "0400";
        content = ''
          DOMAIN=https://vault.${config.sops.placeholder."nest/domain"}
          ADMIN_TOKEN=${config.sops.placeholder."nest/vaultwarden/admin-token"}
        '';
      };

      services.vaultwarden = {
        enable = true;
        environmentFile = [ config.sops.templates."vaultwarden.env".path ];
        config = {
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = 8222;
          SIGNUPS_ALLOWED = false;
          INVITATIONS_ALLOWED = true;
          WEBSOCKET_ENABLED = true;
        };
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/bitwarden_rs"
      ];
    })
  ];
}
