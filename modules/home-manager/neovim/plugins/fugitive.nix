{
  programs.nixvim.plugins.fugitive = {
    enable = true;
  };

  programs.nixvim.keymaps = [
    {
      action = "<cmd>Git<cr>";
      key = "<leader>go";
      mode = "n";
      options = {
        remap = false;
        desc = "vim-fugitive - [g]it [o]pen";
      };
    }
  ];
}
