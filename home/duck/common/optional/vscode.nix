{
  config,
  inputs,
  lib,
  options,
  pkgs,
  ...
}: {
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;

    profiles.default = {
      enableExtensionUpdateCheck = false;
      enableUpdateCheck = false;

      userSettings = {
        "[nix]"."editor.tabSize" = 2;
        "extensions.autoUpdate" = false;
        "editor.formatOnSave" = true;
        "vscoq.proof.mode" = 1;
        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
      };

      extensions = with inputs.nix-vscode-extensions.extensions."x86_64-linux".open-vsx; [
        myriad-dreamin.tinymist
        jnoortheen.nix-ide
        maximedenes.vscoq
      ];
    };
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist/${config.home.homeDirectory}" = {
        directories = [
          # ".config/VSCodium"
        ];
      };
    };
  };
}
