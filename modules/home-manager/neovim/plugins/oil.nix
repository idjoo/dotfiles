{
  programs.nixvim.plugins.oil = {
    enable = true;

    settings = {
      default_file_explorer = true;
      skip_confirm_for_simple_edits = true;
      watch_for_changes = true;
      natural_order = true;

      columns = [
        "icon"
      ];

      view_options = {
        wrap = true;
        show_hidden = true;
        is_always_hidden = {
          __raw = # lua
            ''
              function(name, _)
                return name == '..'
              end
            '';
        };

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
