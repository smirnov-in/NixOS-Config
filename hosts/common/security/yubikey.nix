{
  config,
  lib,
  pkgs,
  ...
}:
let
  rootPath = if config.environment ? "persistence" then "/persist" else "";
in
{
  sops.secrets."yubico/u2f_keys" = {
    owner = "duck";
    inherit (config.users.users.duck) group;
    path = "${rootPath}/home/duck/.config/Yubico/u2f_keys";
  };

  environment = {
    systemPackages = with pkgs; [
      yubioath-flutter
      yubikey-manager
      pam_u2f
    ];
  }
  // lib.optionalAttrs (config.environment ? "persistence") {
    persistence."/persist".users.duck.directories = [
      ".config/Yubico"
    ];
  };

  services.pcscd.enable = true;
  services.udev.packages = [ pkgs.yubikey-personalization ];

  services.yubikey-agent.enable = true;

  security.pam = {
    sshAgentAuth.enable = true;

    u2f = {
      enable = true;
      settings = {
        cue = true;
        authFile = "${rootPath}/home/duck/.config/Yubico/u2f_keys";
      };
    };

    services = {
      login.u2fAuth = true;
      sudo = {
        u2fAuth = true;
        sshAgentAuth = true;
      };
    };
  };
}
