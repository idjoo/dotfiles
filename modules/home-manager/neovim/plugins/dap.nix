{ ... }:
{
  programs.nixvim.plugins.dap = {
    enable = true;

    configurations = {
      python = [
        {
          name = "fastapi";
          type = "debugpy";
          request = "launch";
          module = "fastapi";
          args.__raw = ''
            function()
              return {
                'run',
                '--port=8000',
                '--reload',
              }
            end
          '';
        }
      ];
    };
  };

  programs.nixvim.plugins = {
    dap-ui = {
      enable = true;

      settings = {
        layouts = [
          {
            elements = [
              {
                id = "scopes";
                size = 0.25;
              }
              {
                id = "breakpoints";
                size = 0.25;
              }
              {
                id = "stacks";
                size = 0.25;
              }
              {
                id = "watches";
                size = 0.25;
              }
            ];
            position = "left";
            size = 40;
          }
          {
            elements = [
              {
                id = "repl";
                size = 1;
              }
            ];
            position = "right";
            size = 40;
          }
        ];
      };
    };

    dap-python = {
      enable = true;
    };

    dap-virtual-text = {
      enable = true;
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
