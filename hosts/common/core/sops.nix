{
  config,
  inputs,
  lib,
  options,
  ...
}:
let
  rootPath = if options.environment ? "persistence" then "/persist" else "";
  secretsPath = toString inputs.nix-secrets;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  config = lib.mkMerge [
    {
      sops = {
        defaultSopsFile = "${secretsPath}/secrets.yaml";
        validateSopsFiles = false;

        age = {
          sshKeyPaths = [ "${rootPath}/etc/ssh/ssh_host_ed25519_key" ];
          keyFile = "${rootPath}/var/lib/sops-nix/key.txt";
          generateKey = true;
        };
      };
    }
    (lib.optionalAttrs (options.environment ? "persistence") {
      environment.persistence."/persist".directories = [
        "/var/lib/sops-nix"
      ];
    })
  ];
}
