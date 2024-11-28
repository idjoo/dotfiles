{ ... }:
{
  programs.nixvim.plugins.dap = {
    enable = true;

    configurations = {
      python = [
        {
          name = "FastAPI";
          type = "debugpy";
          request = "launch";
          module = "uvicorn";
          args = {
            __raw = ''
              function()
                return {
                  vim.fn.input(
                    'Module: ',
                    'app:app',
                    'file'
                  ),
                  '--reload',
                }
              end
            '';
          };
        }
      ];
    };

    extensions = {
      dap-ui = {
        enable = true;
      };

      dap-python = {
        enable = true;
      };

      dap-go = {
        enable = true;
      };

      dap-virtual-text = {
        enable = true;
      };
    };
  };

  programs.nixvim.plugins.which-key = {
    settings = {
      spec = [
        {
          __unkeyed-0 = "<leader>d";
          group = "debug";
        }
      ];
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<leader>dd";
      action = {
        __raw = ''
          function() require("dapui").toggle() end
        '';
      };
      mode = "n";
      options = {
        remap = false;
        desc = "nvim-dap - [d]ebug";
      };
    }

    {
      key = "<leader>db";
      action = {
        __raw = ''
          function() require("dap").toggle_breakpoint() end
        '';
      };
      mode = "n";
      options = {
        remap = false;
        desc = "nvim-dap - [d]ebug [b]reakpoint";
      };
    }

    {
      key = "<leader>dc";
      action = {
        __raw = ''
          function() require("dap").continue() end
        '';
      };
      mode = "n";
      options = {
        remap = false;
        desc = "nvim-dap - [d]ebug [c]ontinue";
      };
    }

    {
      key = "<leader>dq";
      action = {
        __raw = ''
          function()
            require("dap.breakpoints").clear()
            require("dap").terminate()
            require("dap").close()
            require("dapui").close()
          end
        '';
      };
      mode = "n";
      options = {
        remap = false;
        desc = "nvim-dap - [d]ebug [q]uit";
      };
    }
  ];
}
