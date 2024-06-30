{
  programs.nixvim.keymaps = [
    {
      action = "P";
      key = "p";
      mode = "x";
      options = {
        remap = false;
      };
    }

    {
      action = "<cmd>nohlsearch<cr>";
      key = "<esc>";
      mode = "n";
    }

    {
      action = ''<cmd>echo "tolol"<cr>'';
      key = "<left>";
      mode = "n";
    }
    {
      action = ''<cmd>echo "tolol"<cr>'';
      key = "<right>";
      mode = "n";
    }
    {
      action = ''<cmd>echo "tolol"<cr>'';
      key = "<up>";
      mode = "n";
    }
    {
      action = ''<cmd>echo "tolol"<cr>'';
      key = "<down>";
      mode = "n";
    }

    {
      action = ''y:let @"=system('base64 --decode', @")<cr>gvP'';
      key = "<leader>64";
      mode = "v";
      options = {
        remap = false;
      };
    }
  ];
}
