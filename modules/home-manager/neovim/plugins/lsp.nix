{
  programs.nixvim.plugins.lsp = {
    enable = true;

    servers = {
      nil-ls.enable = true;
      pylsp.enable = true;
      csharp-ls.enable = true;
    };

    keymaps = {
      diagnostic = {
        "<leader>j" = "goto_next";
        "<leader>k" = "goto_prev";
      };

      lspBuf = {
        K = "hover";
        gD = "references";
        gd = "definition";
        gi = "implementation";
        gt = "type_definition";
      };
    };
  };
}
