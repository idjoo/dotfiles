{
  programs.nixvim.plugins.indent-blankline = {
    enable = true;
    settings = {
      debounce = 100;
      indent = {
        char = "▎";
        smart_indent_cap = true;
      };

      whitespace = {
        highlight = [
          "Whitespace"
          "NonText"
        ];
      };

      scope = {
        show_exact_scope = true;
      };

      viewport_buffer = {
        min = 1;
      };
    };
  };
}
