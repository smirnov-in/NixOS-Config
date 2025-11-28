{
  inputs,
  pkgs,
  ...
}: {
  imports = [inputs.nix-niri.nixosModules.niri];

  programs.niri = {
    enable = true;
  };

  environment.systemPackages = with pkgs; [xwayland-satellite];
}
