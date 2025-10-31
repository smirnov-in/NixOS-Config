{
  config,
  configLib,
  lib,
  options,
  ...
}: let
  pathToKeys = configLib.relativeToRoot "hosts/common/users/${config.home.username}/keys";
in {
  services.ssh-agent.enable = true;

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      addKeysToAgent = "yes";
      userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts.d/hosts";

      controlMaster = "auto";
      controlPath = "~/.ssh/sockets/S.%r@%h:%p";
      controlPersist = "10m";
    };
  };

  home =
    {
      file = {
        ".ssh/id_pike.pub".source = "${pathToKeys}/id_pike.pub";
        ".ssh/id_karp.pub".source = "${pathToKeys}/id_karp.pub";
      };
    }
    // lib.optionalAttrs (options.home ? "persistence") {
      persistence = {
        "/persist/${config.home.homeDirectory}" = {
          directories = [
            ".ssh/known_hosts.d"
            ".ssh/sockets"
          ];
        };
      };
    };

  systemd.user.tmpfiles.rules = [
    "L ${config.home.homeDirectory}/.ssh/known_hosts - - - - ${config.home.homeDirectory}/.ssh/known_hosts.d/hosts"
  ];
}
