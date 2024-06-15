{
  programs.nixvim.plugins.oil = {
    enable = true;

    settings = {
      columns = [
        "icon"
      ];

      # TODO keymaps messy
      keymaps = {
        "g?" = "actions.show_help";
        "<cr>" = "actions.select";
        "<c-s>" = "actions.select_vsplit";
        "<c-h>" = "actions.select_split";
        "<c-t>" = "actions.select_tab";
        "<c-p>" = "actions.preview";
        "<c-c>" = "actions.close";
        "<c-l>" = "actions.refresh";
        "-" = "actions.parent";
        "_" = "actions.open_cwd";
        "`" = "actions.cd";
        "gs" = "actions.change_sort";
        "gx" = "actions.open_external";
        "g." = "actions.toggle_hidden";
      };

      view_options = {
        show_hidden = false;
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<leader>oo";
      action = "<cmd>Oil<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "oil.nvim - [o]il [o]pen";
      };
    }
  ];
}
