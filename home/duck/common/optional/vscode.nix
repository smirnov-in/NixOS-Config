{
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
        # myriad-dreamin.tinymist
        # jnoortheen.nix-ide
        # maximedenes.vscoq
      ];
    };
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        directories = [
          ".config/VSCodium/Backups"
          ".config/VSCodium/blob_storage"
          ".config/VSCodium/Cache"
          ".config/VSCodium/CachedConfigurations"
          ".config/VSCodium/CachedData"
          ".config/VSCodium/CachedExtensionVSIXs"
          ".config/VSCodium/CachedProfilesData"
          ".config/VSCodium/Code Cache"
          ".config/VSCodium/Crashpad"
          ".config/VSCodium/DawnCache"
          ".config/VSCodium/DawnGraphiteCache"
          ".config/VSCodium/DawnWebGPUCache"
          ".config/VSCodium/Dictionaries"
          ".config/VSCodium/GPUCache"
          ".config/VSCodium/Local Storage"
          ".config/VSCodium/logs"
          ".config/VSCodium/Service Worker"
          ".config/VSCodium/Session Storage"
          ".config/VSCodium/Shared Dictionary"
          ".config/VSCodium/User/globalStorage"
          ".config/VSCodium/User/History"
          ".config/VSCodium/User/snippets"
          ".config/VSCodium/User/workspaceStorage"
          ".config/VSCodium/WebStorage"
        ];
      };
    };
  };
}
