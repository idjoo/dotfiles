{
  programs.nixvim.plugins.lspsaga = {
    enable = true;
  };

  programs.nixvim.keymaps = [
    {
      key = "]d";
      action = "<cmd>Lspsaga diagnostic_jump_next<cr>";
      mode = "n";
    }

    {
      key = "[d";
      action = "<cmd>Lspsaga diagnostic_jump_prev<cr>";
      mode = "n";
    }

    {
      key = "<leader>ca";
      action = "<cmd>Lspsaga code_action<cr>";
      mode = "n";
    }

    {
      key = "<leader>f";
      action = "<cmd>Lspsaga show_line_diagnostics<cr>";
      mode = "n";
    }

    {
      key = "K";
      action = "<cmd>Lspsaga hover_doc<cr>";
      mode = "n";
    }

    {
      key = "gt";
      action = "<cmd>Lspsaga goto_type_definition<cr>";
      mode = "n";
    }

    {
      key = "gd";
      action = "<cmd>Lspsaga goto_definition<cr>";
      mode = "n";
    }

    {
      key = "gr";
      action = "<cmd>Lspsaga rename<cr>";
      mode = "n";
    }
  ];
}
