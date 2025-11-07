{
  lib,
  pkgs,
  ...
}:
{
  programs.nixvim.plugins.lsp = {
    enable = true;

    inlayHints = true;

    servers = {
      lua_ls.enable = true;
      nixd.enable = true;
      nil_ls.enable = false;
      pylsp = {
        enable = true;
        settings = {
          plugins = {
            ruff = {
              enabled = true;
            };
          };
        };
      };
      csharp_ls.enable = lib.mkIf pkgs.stdenv.isLinux true;
      gopls.enable = true;
      clangd.enable = true;
      terraformls.enable = true;
      ts_ls = {
        enable = true;
        settings = {
          filetypes = [
            "ts"
            "tsx"
            "js"
            "jsx"
          ];
        };
      };
      jsonls.enable = true;
      yamlls.enable = true;
      jdtls.enable = true;
      taplo.enable = true;
      rust_analyzer = {
        enable = true;
        installRustc = true;
        installCargo = true;
      };
      zls.enable = true;
      vue_ls.enable = true;
      bashls.enable = true;
      dockerls.enable = true;
    };

    keymaps = {
      lspBuf = {
        gD = "references";
        gI = "implementation";
      };
    };
  };

  programs.nixvim.extraConfigLua = ''
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "sop" },
      callback = function()
        local client = vim.lsp.start({
          name = "sop-ls",
          cmd = {"/home/idjo/documents/sop-ls/bin/sop-ls"},
        })
      end,
    })
  '';
}
