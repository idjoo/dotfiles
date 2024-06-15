{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      nixd.enable = true;
      nil-ls.enable = false;
      pylsp.enable = true;
      csharp-ls.enable = true;
      gopls.enable = true;
      rust-analyzer.enable = true;
      clangd.enable = true;
      terraformls.enable = true;
      tsserver.enable = true;
      jsonls.enable = true;
    };

    keymaps = {
      lspBuf = {
        gD = "references";
        gI = "implementation";
      };
    };
  };
}
