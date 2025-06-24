{
  inputs,
  config,
  ...
}: let
  secretsPath = builtins.toString inputs.nix-secrets;
  homeDirectory = config.home.homeDirectory;
in {
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  sops = {
    age.keyFile = "${homeDirectory}/.config/sops/age/keys.txt";

    defaultSopsFile = "${secretsPath}/secrets.yaml";
    validateSopsFiles = false;

    secrets = {
      "ssh-keys/pike" = {
        path = "${homeDirectory}/.ssh/id_pike";
      };
      "ssh-keys/karp" = {
        path = "${homeDirectory}/.ssh/id_karp";
      };
    };
  };
}
