{
  # dependencies
  programs.nixvim.plugins = {
    # luasnip.enable = true;
    # friendly-snippets.enable = true;
  };

  programs.nixvim.plugins.cmp = {
    enable = true;

    autoEnableSources = true;

    settings = {
      snippet = {
        expand = # lua
          ''
            function(args)
              require('luasnip').lsp_expand(args.body)
            end
          '';
      };

      completion = {
        completeopt = "menu,menuone,noselect";
      };

      mapping = {
        "<C-n>" = # lua
          ''
            cmp.mapping.select_next_item()
          '';
        "<C-p>" = # lua
          ''
            cmp.mapping.select_prev_item()
          '';
        "<C-y>" = # lua
          ''
            cmp.mapping.confirm({ select = true })
          '';
        "<C-Space>" = # lua
          ''
            cmp.mapping.complete({})
          '';
        "<C-l>" = # lua
          ''
            cmp.mapping(function()
              if luasnip.expand_or_locally_jumpable() then
                luasnip.expand_or_jump()
              end
            end, { "i", "s" })
          '';
        "<C-h>" = # lua
          ''
            cmp.mapping(function()
              if luasnip.locally_jumpable(-1) then
                luasnip.jump(-1)
              end
            end, { "i", "s" })
          '';
      };

      sources = [
        { name = "nvim_lua"; }
        { name = "nvim_lsp"; }
        { name = "dap"; }
        { name = "calc"; }
        { name = "conventionalcommits"; }
        { name = "emoji"; }
        { name = "luasnip"; }
        { name = "render-markdown"; }
        { name = "path"; }
        { name = "buffer"; }
      ];
    };
  };
}
