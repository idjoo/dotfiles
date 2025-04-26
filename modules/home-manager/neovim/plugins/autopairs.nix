{
  programs.nixvim.plugins.nvim-autopairs = {
    enable = true;

    lazyLoad = {
      enable = true;
      settings = {
        event = "InsertEnter";
      };
    };
  };
}
