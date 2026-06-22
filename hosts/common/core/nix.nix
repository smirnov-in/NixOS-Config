{
  config,
  inputs,
  ...
}:
{
  sops.secrets.github-nix-token = {
    mode = "0440";
    owner = "root";
    group = "nixbld";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      warn-dirty = false;

      substituters = [
        "https://mirror.yandex.ru/nixos/"
        "https://cache.nixos.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      ];
      connect-timeout = 5;
      stalled-download-timeout = 60;
      fallback = true;
    };

    extraOptions = "!include ${config.sops.secrets.github-nix-token.path}";

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];
  };

  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = _: true;
  };

  programs.nh = {
    enable = true;
    clean = {
      enable = true;
      extraArgs = "--keep-since 4d --keep 3";
    };
  };
}
