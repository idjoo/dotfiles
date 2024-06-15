{
  programs.nixvim.plugins.telescope = {
    enable = true;
    keymaps = {
      "<leader>fg" = {
        action = "live_grep";
        options = {
          remap = false;
          desc = "telescope.nvim - [f]ile [g]rep";
        };
      };

      "<leader>ff" = {
        action = "find_files";
        options = {
          remap = false;
          desc = "telescope.nvim - [f]ile [f]ind";
        };
      };

      "<leader>fq" = {
        action = "quickfix";
        options = {
          remap = false;
          desc = "telescope.nvim - [f]ind [q]uickfix";
        };
      };
    };
  };
}
