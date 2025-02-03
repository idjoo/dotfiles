{
  programs.nixvim.plugins.diffview = {
    enable = true;
  };

  programs.nixvim.plugins.neogit = {
    enable = true;

    lazyLoad = {
      enable = true;
      settings = {
        cmd = "Neogit";
      };
    };

    settings = {
      disable_insert_on_commit = true;

      graph_style = "unicode";

      ignored_settings = [
        "NeogitPushPopup--force"
        "NeogitCommitPopup--allow-empty"
        "NeogitRevertPopup--no-edit"
      ];

      commit_editor = {
        kind = "floating";
      };

      integrations = {
        diffview = true;
        telescope = true;
      };

      mappings = {
        popup = {
          w = false;
          W = "WorktreePopup";
        };
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      action = "<cmd>Neogit<cr>";
      key = "<leader>gg";
      mode = "n";
      options = {
        remap = false;
        desc = "neogit - [g]it";
      };
    }
  ];
}
