{
  programs.nixvim = {
    autoGroups = {
      highlight_yank = {
        clear = true;
      };
    };

    autoCmd = [
      {
        event = [ "TextYankPost" ];
        desc = "Highlight when yanking (copying) text";
        group = "highlight_yank";
        callback = {
          __raw = "function() vim.highlight.on_yank() end";
        };
      }
    ];
  };
}
