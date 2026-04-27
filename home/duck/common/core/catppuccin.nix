{inputs, ...}: {
  imports = [inputs.nix-catppuccin.homeModules.catppuccin];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "latte";
  };
}
