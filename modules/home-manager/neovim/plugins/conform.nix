{ lib, pkgs, ... }:
{
  programs.nixvim.plugins.conform-nvim = {
    enable = true;

    lazyLoad = {
      enable = true;

      settings = {
        event = [ "BufWritePre" ];
        cmd = [ "ConformInfo" ];
        keys = [
          {
            __unkeyed-0 = "<leader>bf";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("conform").format({ async = true, lsp_format = "fallback" }) end
                '';
            };
            desc = "conform.nvim - [b]uffer [f]ormat";
          }
        ];
      };
    };

    luaConfig = {
      post = # lua
        ''
          vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
        '';
    };

    settings = {
      default_format_opts.lsp_format = "prefer";

      formatters_by_ft = {
        nix = [ "nixfmt" ];
        go = [ "gofmt" ];
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
        javascript = [ "prettierd" ];
        typescript = [ "prettierd" ];
        javascriptreact = [ "prettierd" ];
        typescriptreact = [ "prettierd" ];
        markdown = [ "prettierd" ];
        sh = [
          "shellcheck"
          "shellharden"
          "shfmt"
        ];
        json = [ "jq" ];
        yaml = [ "yamlfmt" ];
        java = [ "google-java-format" ];
        html = [ "prettierd" ];
        css = [ "prettierd" ];
        rust = [ "rustfmt" ];
        python = [
          "ruff_fix"
          "ruff_format"
          "ruff_organize_imports"
        ];
        sql = [ "sqlfluff" ];

        "_" = [ "trim_whitespace" ];
      };

      formatters = {
        nixfmt = {
          command = lib.getExe pkgs.nixfmt-rfc-style;
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
          prepend_args = [
            "-formatter"
            (builtins.concatStringsSep "," [
              "retain_line_breaks_single=true"
              "max_line_length=80"
              "trim_trailing_whitespace=true"
            ])
          ];
        };

        google-java-format = {
          command = lib.getExe pkgs.google-java-format;
        };

        rustfmt = {
          command = lib.getExe pkgs.rustfmt;
        };

        ruff_fix = {
          command = lib.getExe pkgs.ruff;
        };

        ruff_format = {
          command = lib.getExe pkgs.ruff;
        };

        ruff_organize_imports = {
          command = lib.getExe pkgs.ruff;
        };

        sqlfluff = {
          command = lib.getExe pkgs.sqlfluff;
        };
      };
    };
  };
}
