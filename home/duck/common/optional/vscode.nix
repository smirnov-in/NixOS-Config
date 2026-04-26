{
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
        "extensions.autoUpdate" = false;
        "editor.formatOnSave" = true;
        "editor.fontFamily" = "JetBrains Mono";
        "editor.fontLigatures" = true;
      };

      extensions = with pkgs.vscode-extensions; [
        rocq-prover.vsrocq
        leanprover.lean4
        tamasfe.even-better-toml
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
