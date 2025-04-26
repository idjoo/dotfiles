{
  programs.nixvim.plugins.comment = {
    enable = true;

    settings = {
      sticky = true;

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
