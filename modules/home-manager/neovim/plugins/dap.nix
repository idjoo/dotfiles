{ ... }:
{
  programs.nixvim.plugins.dap = {
    enable = true;

    lazyLoad = {
      enable = true;

      settings = {
        keys = [
          {
            __unkeyed-0 = "<leader>dd";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dapui").toggle() end
                '';
            };
            desc = "nvim-dap - Toggle UI";
          }

          {
            __unkeyed-0 = "<leader>dq";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function()
                    require("dap.breakpoints").clear()
                    require("dap").terminate()
                    require("dap").close()
                    require("dapui").close()
                  end
                '';
            };
            desc = "nvim-dap - Quit";
          }

          {
            __unkeyed-0 = "<leader>dB";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end
                '';
            };
            desc = "nvim-dap - Breakpoint Condition";
          }

          {
            __unkeyed-0 = "<leader>db";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").toggle_breakpoint() end
                '';
            };
            desc = "nvim-dap - Toggle Breakpoint";
          }

          {
            __unkeyed-0 = "<leader>dc";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").continue() end
                '';
            };
            desc = "nvim-dap - Run/Continue";
          }

          {
            __unkeyed-0 = "<leader>da";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").continue({ before = get_args }) end
                '';
            };
            desc = "nvim-dap - Run with Args";
          }

          {
            __unkeyed-0 = "<leader>dC";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").run_to_cursor() end
                '';
            };
            desc = "nvim-dap - Run to Cursor";
          }

          {
            __unkeyed-0 = "<leader>dg";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").goto_() end
                '';
            };
            desc = "nvim-dap - Go to Line (No Execute)";
          }

          {
            __unkeyed-0 = "<leader>di";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").step_into() end
                '';
            };
            desc = "nvim-dap - Step Into";
          }

          {
            __unkeyed-0 = "<leader>dj";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").down() end
                '';
            };
            desc = "nvim-dap - Down";
          }

          {
            __unkeyed-0 = "<leader>dk";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").up() end
                '';
            };
            desc = "nvim-dap - Up";
          }

          {
            __unkeyed-0 = "<leader>dl";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").run_last() end
                '';
            };
            desc = "nvim-dap - Run Last";
          }

          {
            __unkeyed-0 = "<leader>do";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").step_out() end
                '';
            };
            desc = "nvim-dap - Step Out";
          }

          {
            __unkeyed-0 = "<leader>dO";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").step_over() end
                '';
            };
            desc = "nvim-dap - Step Over";
          }

          {
            __unkeyed-0 = "<leader>dP";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").pause() end
                '';
            };
            desc = "nvim-dap - Pause";
          }

          {
            __unkeyed-0 = "<leader>dr";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").repl.toggle() end
                '';
            };
            desc = "nvim-dap - Toggle REPL";
          }

          {
            __unkeyed-0 = "<leader>ds";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").session() end
                '';
            };
            desc = "nvim-dap - Session";
          }

          {
            __unkeyed-0 = "<leader>dt";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap").terminate() end
                '';
            };
            desc = "nvim-dap - Terminate";
          }

          {
            __unkeyed-0 = "<leader>dw";
            __unkeyed-1 = {
              __raw = # lua
                ''
                  function() require("dap.ui.widgets").hover() end
                '';
            };
            desc = "nvim-dap - Widgets";
          }

        ];
      };
    };

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
        {
          name = "fastapi:args";
          type = "debugpy";
          request = "launch";
          module = "fastapi";
          args.__raw = ''
            function()
              return {
                'run',
                '--port=8000',
                '--reload',
                vim.fn.input('Arguments: '),
              }
            end
          '';
        }
        {
          name = "unittest:args";
          type = "debugpy";
          request = "launch";
          module = "unittest";
          args.__raw = ''
            function()
              return {
                vim.fn.input('Arguments: '),
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

}
