{inputs, ...}: {
  imports = [inputs.nix-catppuccin.nixosModules.catppuccin];

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "latte";
  };
}
