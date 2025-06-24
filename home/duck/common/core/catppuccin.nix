{inputs, ...}: {
  imports = [
    inputs.nix-catppuccin.homeModules.catppuccin
  ];

  catppuccin = {
    flavor = "frappe";
    enable = true;
    gtk.enable = false;

    mako.enable = false;
  };
}
