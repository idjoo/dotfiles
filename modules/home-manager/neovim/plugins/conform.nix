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
            __unkeyed-1 = "<leader>bf";
            __unkeyed-3 = {
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
      formatters_by_ft = {
        nix = [ "nixfmt" ];
        go = [ "gofmt" ];
        c = [ "clang-format" ];
        cpp = [ "clang-format" ];
        javascript = [ "prettierd" ];
        javascriptreact = [ "prettierd" ];
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
      };
    };
  };
}
