{
  inputs,
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  imports = [ inputs.nix-niri.nixosModules.niri ];

  services.displayManager = {
    gdm.enable = true;
    defaultSession = "niri";
  };

  programs.niri = {
    enable = true;
    package = inputs.nix-niri.packages.${system}.niri-stable;
  };

  environment.systemPackages = with pkgs; [
    xwayland-satellite
    nautilus
    papers
  ];
}
