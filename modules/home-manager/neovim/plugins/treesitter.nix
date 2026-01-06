{ pkgs, ... }:
{
  config = {
    programs.nixvim = {
      plugins = {
        treesitter = {
          enable = true;

          # Native Neovim treesitter features
          highlight.enable = true;
          indent.enable = true;

          settings = {
            highlight = {
              additional_vim_regex_highlighting = true;
            };

            incremental_selection = {
              enable = true;

              # TODO messy keymaps
              keymaps = {
                init_selection = "gnn";
                node_decremental = "grm";
                node_incremental = "grn";
                scope_incremental = "grc";
              };
            };
          };

          grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
            javascript
            nix
            python
          ];
        };
      };
    };
  };
}
