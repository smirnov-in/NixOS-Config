{ lib, options, ... }:
{
  config = lib.optionalAttrs (options.environment ? "persistence") {
    environment.persistence."/persist".directories = [
      "/var/lib/postgresql"
    ];
  };
}
