{
  lib,
  options,
  ...
}:
{
  config = lib.mkMerge [
    {
      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          PermitRootLogin = "no";
        };
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/etc/ssh"
      ];
    })
  ];
}
