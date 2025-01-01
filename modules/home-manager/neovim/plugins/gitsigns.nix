{
  programs.nixvim.plugins.gitsigns = {
    enable = true;

    settings = {
      signs = {
        add = {
          text = "│";
        };
        change = {
          text = "│";
        };
        delete = {
          text = "󰍵";
        };
        topdelete = {
          text = "‾";
        };
        changedelete = {
          text = "~";
        };
        untracked = {
          text = "│";
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      action = "<cmd>Gitsigns blame<cr>";
      key = "<leader>gb";
      mode = "n";
      options = {
        remap = false;
        desc = "gitsigns - [g]it [b]lame";
      };
    }
  ];
}
