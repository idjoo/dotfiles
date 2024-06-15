{
  programs.nixvim.plugins.lsp = {
    enable = true;
    servers = {
      nil-ls.enable = true;
      pylsp.enable = true;
    };
  };
}
