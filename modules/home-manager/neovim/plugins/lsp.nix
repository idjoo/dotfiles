{
  programs.nixvim.plugins.lsp = {
    enable = true;

    inlayHints = true;

    servers = {
      lua-ls.enable = true;
      nixd.enable = true;
      nil-ls.enable = false;
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
      csharp-ls.enable = true;
      gopls.enable = true;
      clangd.enable = true;
      terraformls.enable = true;
      ts-ls.enable = true;
      jsonls.enable = true;
      jdt-language-server.enable = true;
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
