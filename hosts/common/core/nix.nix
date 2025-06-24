{inputs, ...}: {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = "nix-command flakes";
      warn-dirty = false;
    };

    nixPath = ["nixpkgs=${inputs.nixpkgs}"];
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
