{
  programs.nixvim.plugins.which-key = {
    enable = true;

    settings = {
      spec = [
        {
          __unkeyed = "<leader>b";
          group = "buffers";
        }
        {
          __unkeyed = "<leader>l";
          group = "lsp";
        }
        {
          __unkeyed = "<leader>f";
          group = "files";
        }
        {
          __unkeyed = "<leader>o";
          group = "oil.nvim";
        }
        {
          __unkeyed = "<leader>g";
          group = "git";
        }
        {
          __unkeyed = "<leader>r";
          group = "rest.nvim";
          icon = "";
        }
      ];
    };
  };
}
