{
  programs.nixvim.plugins.lsp-format.enable = true;
  programs.nixvim.plugins.none-ls = {
    enable = true;
    enableLspFormat = true;
    sources = {
      formatting = {
        nixpkgs_fmt.enable = true;
        gofmt.enable = true;
      };
    };
  };
}
