{ lib, pkgs, ... }:
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;

    settings = {
      formatters_by_ft = {
        nix = [ "nixpkgs-fmt" ];
        go = [ "gofmt" ];
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
        javascript = [ "prettierd" ];
        sh = [
          "shellcheck"
          "shellharden"
          "shfmt"
        ];
        json = [ "jq" ];
        yaml = [ "yamlfmt" ];
        java = [ "google-java-format" ];
        html = [ "prettierd" ];

        "_" = [ "trim_whitespace" ];
      };

      formatters = {
        nixpkgs-fmt = {
          command = lib.getExe pkgs.nixpkgs-fmt;
        };

        gofmt = {
          command = lib.getExe' pkgs.go "gofmt";
        };

        clang-format = {
          command = lib.getExe' pkgs.clang-tools "clang-format";
        };

        prettierd = {
          command = lib.getExe pkgs.prettierd;
        };

        shellcheck = {
          command = lib.getExe pkgs.shellcheck;
        };

        shellharden = {
          command = lib.getExe pkgs.shellharden;
        };

        shfmt = {
          command = lib.getExe pkgs.shfmt;
        };

        jq = {
          command = lib.getExe pkgs.jq;
        };

        yamlfmt = {
          command = lib.getExe pkgs.yamlfmt;
        };

        google-java-format = {
          command = lib.getExe pkgs.google-java-format;
        };
      };
    };
  };

  programs.nixvim.extraConfigLua = ''
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  '';

  programs.nixvim.keymaps = [
    {
      key = "<leader>bf";
      action = {
        __raw = ''
          function() require("conform").format({ async = true, lsp_format = "fallback" }) end
        '';
      };
      mode = "n";
      options = {
        remap = false;
        desc = "conform.nvim - [b]uffer [f]ormat";
      };
    }
  ];
}
