{
  programs.nixvim.plugins.barbar = {
    enable = true;

    keymaps = {
      close = {
        key = "<leader>bd";
        options = {
          remap = false;
          desc = "barbar.nvim - [b]uffer [d]elete";
        };
      };

      next = {
        key = "<leader>bn";
        options = {
          remap = false;
          desc = "barbar.nvim - [b]uffer [n]ext";
        };
      };

      previous = {
        key = "<leader>bp";
        options = {
          remap = false;
          desc = "barbar.nvim - [b]uffer [p]revious";
        };
      };
    };
  };
}
