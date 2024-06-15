{
  programs.nixvim.plugins.lspsaga = {
    enable = true;
  };

  programs.nixvim.keymaps = [
    {
      key = "<leader>ldn";
      action = "<cmd>Lspsaga diagnostic_jump_next<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [d]iagnostic [n]ext";
      };
    }

    {
      key = "<leader>ldp";
      action = "<cmd>Lspsaga diagnostic_jump_prev<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [d]iagnostic [p]revious";
      };
    }

    {
      key = "<leader>lca";
      action = "<cmd>Lspsaga code_action<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [c]ode [a]ction";
      };
    }

    {
      key = "<leader>lds";
      action = "<cmd>Lspsaga show_line_diagnostics<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [d]iagnostic [s]how";
      };
    }

    {
      key = "K";
      action = "<cmd>Lspsaga hover_doc<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - hover documentation";
      };
    }

    {
      key = "<leader>lgd";
      action = "<cmd>Lspsaga goto_definition<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [g]oto [d]efinition";
      };
    }

    {
      key = "<leader>lgt";
      action = "<cmd>Lspsaga goto_type_definition<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [g]oto [t]ype definition";
      };
    }

    {
      key = "<leader>lr";
      action = "<cmd>Lspsaga rename<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "lspsaga.nvim - [l]sp [r]ename";
      };
    }
  ];
}
