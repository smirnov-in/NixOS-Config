{config, ...}: {
  imports = [
    ./atuin.nix
    ./bat.nix
    ./btop.nix
    ./catppuccin.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./fish.nix
    ./git.nix
    ./helix.nix
    ./ripgrep.nix
    ./sops.nix
    ./ssh.nix
    ./starship.nix
    ./yazi.nix
    ./zellij.nix
    ./zoxide.nix
  ];

  home = {
    username = "duck";
    homeDirectory = "/home/${config.home.username}";

    shell.enableFishIntegration = true;

    sessionVariables = {
      FLAKE = "$HOME/Projects/NixOS-Config";
      NH_FLAKE = "$HOME/Projects/NixOS-Config";
      TERMINAL = "kitty";
      VISUAL = "hx";
      EDITOR = "hx";
    };
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
