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
      integrations = {
        diffview = true;
        telescope = true;
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
