{
  config,
  configLib,
  lib,
  options,
  ...
}: let
  pathToKeys = configLib.relativeToRoot "hosts/common/users/${config.home.username}/keys";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks."*" = {
      userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts.d/hosts";
      controlMaster = "auto";
      controlPath = "${config.home.homeDirectory}/.ssh/sockets/S.%r@%h:%p";
      controlPersist = "10m";

      addKeysToAgent = "yes";
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
        "/persist" = {
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
