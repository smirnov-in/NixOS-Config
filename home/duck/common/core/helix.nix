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

      keys = {
        insert = {
          j.j = "normal_mode";
        };
      };
    };

    languages = {
      language-server = {
        nixd = {
          command = "nixd";
        };

        coq-lsp = {
          command = "coq-lsp";
        };
      };

      language = [
        {
          name = "nix";
          scope = "source.nix";
          injection-regex = "nix";
          file-types = ["nix"];
          comment-token = "#";
          formatter.command = "alejandra";
          auto-format = true;
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          language-servers = ["nixd"];
        }
        {
          name = "coq";
          scope = "source.v";
          file-types = ["v"];
          block-comment-tokens = {
            start = "(*";
            end = "*)";
          };
          indent = {
            tab-width = 2;
            unit = "  ";
          };
          language-servers = ["coq-lsp"];
        }
      ];
    };
  };

  home.packages = with pkgs; [
    alejandra
    nixd
    wl-clipboard
  ];
}
