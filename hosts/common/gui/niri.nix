{ pkgs, ... }:
{
  services.displayManager = {
    gdm.enable = true;
    defaultSession = "niri";
  };

  programs.niri.enable = true;

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
    papers
  ];
}
