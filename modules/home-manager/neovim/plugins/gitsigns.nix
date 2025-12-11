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

  programs.nixvim.plugins.which-key = {
    settings = {
      spec = [
        {
          __unkeyed-0 = "<leader>gs";
          group = "stage";
        }
      ];
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

    {
      action = "<cmd>Gitsigns stage_hunk<cr>";
      key = "<leader>gsh";
      mode = "n";
      options = {
        remap = false;
        desc = "gitsigns - [g]it [s]tage [h]unk";
      };
    }

    {
      action = "<cmd>Gitsigns stage_buffer<cr>";
      key = "<leader>gsb";
      mode = "n";
      options = {
        remap = false;
        desc = "gitsigns - [g]it [s]tage [b]uffer";
      };
    }
  ];
}
