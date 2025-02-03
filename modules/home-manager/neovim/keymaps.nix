{
  programs.nixvim.keymaps = [
    {
      key = "p";
      action = "P";
      mode = "x";
      options = {
        remap = false;
      };
    }

    {
      key = "<esc>";
      action = "<cmd>nohlsearch<cr>";
      mode = "n";
      options = {
        remap = false;
      };
    }

    # Disable arrows movement
    {
      key = "<left>";
      action = ''<cmd>echo "tolol"<cr>'';
      mode = "n";
      options = {
        remap = false;
      };
    }
    {
      key = "<right>";
      action = ''<cmd>echo "tolol"<cr>'';
      mode = "n";
      options = {
        remap = false;
      };
    }
    {
      key = "<up>";
      action = ''<cmd>echo "tolol"<cr>'';
      mode = "n";
      options = {
        remap = false;
      };
    }
    {
      key = "<down>";
      action = ''<cmd>echo "tolol"<cr>'';
      mode = "n";
      options = {
        remap = false;
      };
    }

    # Base64
    {
      key = "<leader>64d";
      action = ''y:let @"=system('base64 --decode', @")<cr>gvP'';
      mode = "v";
      options = {
        remap = false;
        desc = "base64 - base[64] [d]ecode";
      };
    }
    {
      key = "<leader>64e";
      action = ''y:let @"=system('base64', @")<cr>gvP'';
      mode = "v";
      options = {
        remap = false;
        desc = "base64 - base[64] [e]ncode";
      };
    }
  ];
}
