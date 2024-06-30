{
  programs.nixvim.plugins.barbar = {
    enable = true;
    keymaps = {
      close.key = "<leader>bd";
      next.key = "]b";
      previous.key = "[b";
    };
  };
}
