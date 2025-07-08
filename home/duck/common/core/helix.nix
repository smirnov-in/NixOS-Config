{pkgs, ...}: {
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      editor = {
        line-number = "relative";
        bufferline = "always";
        end-of-line-diagnostics = "hint";
        inline-diagnostics = {
          cursor-line = "error";
        };
      };
    };

    languages.language = [
      {
        name = "nix";
        formatter.command = "alejandra";
        auto-format = true;
      }
    ];
  };

  home.packages = with pkgs; [
    alejandra
    nixd
    wl-clipboard
  ];
}
