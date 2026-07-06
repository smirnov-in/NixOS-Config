{ config, ... }: {
  imports = [
    ./cli/atuin.nix
    ./cli/bat.nix
    ./cli/btop.nix
    ./cli/direnv.nix
    ./cli/eza.nix
    ./cli/fd.nix
    ./cli/git.nix
    ./cli/helix.nix
    ./cli/ripgrep.nix
    ./cli/starship.nix
    ./cli/yazi.nix
    ./cli/zellij.nix
    ./cli/zoxide.nix

    ./security/sops.nix
    ./security/ssh.nix

    ./shell/fish.nix
  ];

  home = {
    username = "duck";
    homeDirectory = "/home/${config.home.username}";

    sessionVariables = {
      FLAKE = "${config.home.homeDirectory}/Projects/NixOS-Config";
      NH_FLAKE = "${config.home.homeDirectory}/Projects/NixOS-Config";
    };
  };

  programs.home-manager.enable = true;
  systemd.user.startServices = "sd-switch";
}
