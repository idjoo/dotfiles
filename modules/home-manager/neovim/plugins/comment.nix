{
  programs.nixvim.plugins.comment = {
    enable = true;
    settings = {
      opleader = {
        block = "gb";
        line = "gc";
      };

      toggler = {
        block = "gbc";
        line = "gcc";
      };

      mappings = {
        basic = true;
        extra = true;
      };
    };
  };
}
