{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    just
  ];

  services.flatpak.enable = true;
}
