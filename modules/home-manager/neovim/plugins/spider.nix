{ pkgs, ... }: {                                                                      
  programs.nixvim.plugins.lazy.plugins = [
    {
      pkg = pkgs.vimPlugins.nvim-spider;
      lazy = true;
    }
  ];
}
