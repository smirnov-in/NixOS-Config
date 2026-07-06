{ pkgs, ... }: {
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
        formatter.command = "nixfmt";
        auto-format = true;
      }
    ];
  };

  home.packages = with pkgs; [
    nixfmt
    nixd
  ];

  home.sessionVariables = {
    EDITOR = "hx";
    VISUAL = "hx";
  };
}
