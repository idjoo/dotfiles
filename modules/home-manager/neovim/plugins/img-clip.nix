{
  programs.nixvim.plugins.img-clip = {
    enable = true;

    lazyLoad = {
      enable = true;
      settings = {
        cmd = [ "PasteImage" ];
        keys = [
          {
            __unkeyed-0 = "<leader>p";
            __unkeyed-1 = "<cmd>PasteImage<cr>";
            desc = "img-clip.nvim - Paste image from clipboard";
          }
        ];
      };
    };
  };
}
