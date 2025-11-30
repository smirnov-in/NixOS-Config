{inputs, ...}: {
  imports = [inputs.nix-catppuccin.homeModules.catppuccin];

  catppuccin = {
    enable = true;
  };
}
