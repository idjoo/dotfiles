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
      action = ''<cmd> echo "tolol" <cr>'';
      key = "<left>";
      mode = "n";
    }
    {
      action = ''<cmd> echo "tolol" <cr>'';
      key = "<right>";
      mode = "n";
    }
    {
      action = ''<cmd> echo "tolol" <cr>'';
      key = "<up>";
      mode = "n";
    }
    {
      action = ''<cmd> echo "tolol" <cr>'';
      key = "<down>";
      mode = "n";
    }
  ];
}
