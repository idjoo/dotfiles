{ lib, pkgs, ... }:
{
  programs.nixvim.plugins.dap = {
    enable = true;

    adapters = {
      servers = {
        delve = {
          host = "127.0.0.1";
          port = "\${port}";

          executable = {
            command = lib.getExe pkgs.delve;
            args = [
              "dap"
              "-l"
              "127.0.0.1:\${port}"
              "--log"
              "--log-output=dap"
            ];
          };
        };
      };
    };

    configurations = {
      go = [
        {
          name = "delve";
          type = "delve";
          request = "launch";
          program = "\${file}";
        }
      ];
    };

    extensions = {
      dap-ui = {
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
  ];
}
