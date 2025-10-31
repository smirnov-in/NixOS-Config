{inputs, ...}: {
  imports = [
    inputs.nix-catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    flavor = "macchiato";
    enable = true;
  };
}
