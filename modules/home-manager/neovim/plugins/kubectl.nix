{ pkgs, ... }:
let
  kubectl-nvim = pkgs.vimUtils.buildVimPlugin {
    pname = "kubectl-nvim";
    version = "main";
    src = pkgs.fetchFromGitHub {
      owner = "Ramilito";
      repo = "kubectl.nvim";
      rev = "8bd995ea0f1289c03cb3c96db70125d3cba7588c";
      hash = "sha256-e9zeU1fraqDihS2EW2DXTMU3/kXncGBqPR3X6y6N0tk=";
    };
  };
in
{
  programs.nixvim.extraPlugins = [
    kubectl-nvim
  ];

  programs.nixvim.extraConfigLua = ''
    require("kubectl").setup({
      auto_refresh = {
        enabled = true,
        interval = 1000,
      },
    })
  '';

  programs.nixvim.plugins.which-key = {
    settings = {
      spec = [
        {
          __unkeyed-0 = "<leader>k";
          icon = "󱃾";
          group = "kubectl";
        }
      ];
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<leader>kk";
      action = {
        __raw = ''
          function() require("kubectl").toggle() end
        '';
      };
      mode = "n";
      options = {
        remap = false;
        desc = "kubectl.nvim - [k]ubectl";
      };
    }
  ];
}
