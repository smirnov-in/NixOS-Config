{
  config,
  inputs,
  ...
}: let
  rootPath =
    if config.environment ? "persistence"
    then "/persist/system"
    else "";
  secretsPath = builtins.toString inputs.nix-secrets;
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  sops = {
    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;

    age = {
      sshKeyPaths = ["${rootPath}/etc/ssh/ssh_host_ed25519_key"];
      keyFile = "${rootPath}/var/lib/sops-nix/key.txt";
      generateKey = true;
    };
  };
}
