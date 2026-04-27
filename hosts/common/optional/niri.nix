{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-niri.nixosModules.niri];

  # services.displayManager.gdm = {
  #   enable = true;
  # };

  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
    papers
  ];
}
