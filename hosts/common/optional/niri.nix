{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-niri.nixosModules.niri];

  services.displayManager.gdm = {
    enable = true;
    wayland = true;
  };

  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [xwayland-satellite];
}
