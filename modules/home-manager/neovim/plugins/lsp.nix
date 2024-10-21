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
      csharp_ls.enable = true;
      gopls.enable = true;
      clangd.enable = true;
      terraformls.enable = true;
      ts_ls.enable = true;
      jsonls.enable = true;
      yamlls.enable = true;
      jdtls.enable = true;
      taplo.enable = true;
    };

    keymaps = {
      lspBuf = {
        gD = "references";
        gI = "implementation";
      };
    };
  };

  programs.nixvim.extraConfigLua = ''
    local client = vim.lsp.start_client {
      name = "sop-ls",
      cmd = {"/home/idjo/documents/sop-language-server/bin/sop-language-server"},
    }

    if not client then
      vim.notify("client error")
      return
    end

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "*",
      callback = function()
        vim.lsp.buf_attach_client(0, client)
      end,
    })
  '';
}
