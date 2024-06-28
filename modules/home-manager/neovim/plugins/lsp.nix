{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      nil-ls.enable = true;
      pylsp.enable = true;
      csharp-ls.enable = true;
      gopls.enable = true;
      rust-analyzer.enable = true;
    };

    keymaps = {
      lspBuf = {
        gD = "references";
        gI = "implementation";
      };
    };
  };
}
