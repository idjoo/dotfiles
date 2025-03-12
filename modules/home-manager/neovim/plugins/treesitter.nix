{ pkgs, ... }:
let
  tree-sitter-sop = pkgs.fetchFromGitHub {
    owner = "idjoo";
    repo = "tree-sitter-sop";
    rev = "c233556de082f9430b39eeddf6a396cd928a1aff";
    hash = "sha256-wB0SwOlo2gwzgYFBBaW4jxvBBKMI+4fuIPfHIgu5e5w=";
  };

  treesitter-sop-grammar =
    (pkgs.tree-sitter.buildGrammar {
      language = "sop";
      src = tree-sitter-sop;
      version = "0.1.0";
    }).overrideAttrs
      (drv: {
        fixupPhase = ''
          mkdir -p $out/queries/sop
          mv $out/queries/*.scm $out/queries/sop/
        '';
      });
in
{
  config = {
    programs.nixvim = {
      plugins = {
        treesitter = {
          enable = true;

          settings = {
            auto_install = false;

            ensure_installed = [
              "nix"
              "python"
              "javascript"
            ];

            highlight = {
              enable = true;

              additional_vim_regex_highlighting = true;
              custom_captures = { };
              disable = [ ];
            };

            ignore_install = [ ];

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

            indent = {
              enable = true;
            };

            parser_install_dir = {
              __raw = "vim.fs.joinpath(vim.fn.stdpath('data'), 'treesitter')";
            };

            sync_install = false;
          };

          grammarPackages = pkgs.vimPlugins.nvim-treesitter.passthru.allGrammars ++ [
            treesitter-sop-grammar
          ];
        };
      };

      extraConfigLua = ''
        do
          local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
          -- change the following as needed
          parser_config.sop = {
            install_info = {
              url = "${tree-sitter-sop}",                 -- local path or git repo
              files = {"src/parser.c"},                   -- note that some parsers also require src/scanner.c or src/scanner.cc
              requires_generate_from_grammar = false,     -- if folder contains pre-generated src/parser.c

              -- optional entries:
              -- branch = "master",                       -- default branch in case of git repo if different from master
              -- generate_requires_npm = false,           -- if stand-alone parser without npm dependencies
            },
            filetype = "sop",                             -- if filetype does not match the parser name
          }
        end
      '';

      # Add as extra plugins so that their `queries/{language}/*.scm` get
      # installed and can be picked up by `tree-sitter`
      extraPlugins = [
        treesitter-sop-grammar
      ];
    };
  };
}
