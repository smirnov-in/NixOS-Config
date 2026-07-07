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
          AllowUsers = [ "duck" ];
          KbdInteractiveAuthentication = false;
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
