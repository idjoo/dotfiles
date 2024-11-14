{
  programs.nixvim.plugins.rest = {
    enable = true;
    enableTelescope = true;

    settings = {
      # @type table<string, fun():string> Table of custom dynamic variables
      custom_dynamic_variables = { };

      # @class rest.Config.Request
      request = {
        # @type boolean Skip SSL verification, useful for unknown certificates
        skip_ssl_verification = true;

        # Default request hooks
        # @class rest.Config.Request.Hooks
        hooks = {
          # @type boolean Encode URL before making request
          encode_url = true;

          # @type string Set `User-Agent` header when it is empty
          user_agent = {
            __raw = ''
              "rest.nvim v" .. require("rest-nvim.api").VERSION
            '';
          };

          # @type boolean Set `Content-Type` header when it is empty and body is provided
          set_content_type = true;
        };
      };

      # @class rest.Config.Response
      response = {
        # Default response hooks
        # @class rest.Config.Response.Hooks
        hooks = {
          # @type boolean Decode the request URL segments on response UI to improve readability
          decode_url = true;
          # @type boolean Format the response body using `gq` command
          format = true;
        };
      };

      # @class rest.Config.Clients
      clients = {
        curl = {
          # Statistics to be shown, takes cURL's `--write-out` flag variables
          # See `man curl` for `--write-out` flag
          # @type RestStatisticsStyle[]
          statistics = [
            {
              id = "time_total";
              winbar = "take";
              title = "Time taken";
            }
            {
              id = "size_download";
              winbar = "size";
              title = "Download size";
            }
            {
              id = "remote_ip";
              winbar = "ip";
              title = "Remote IP";
            }
            {
              id = "remote_port";
              winbar = "port";
              title = "Remote Port";
            }
          ];

          # Curl-secific request/response hooks
          # @class rest.Config.Clients.Curl.Opts
          opts = {
            # @type boolean Add `--compressed` argument when `Accept-Encoding` header includes
            # `gzip`
            set_compressed = false;
          };
        };
      };

      # @class rest.Config.Cookies
      cookies = {
        # @type boolean Whether enable cookies support or not
        enable = true;
        # @type string Cookies file path
        path = {
          __raw = ''
            vim.fs.joinpath(vim.fn.stdpath("data") --[[@as string]], "rest-nvim.cookies")
          '';
        };
      };

      # @class rest.Config.Env
      env = {
        # @type boolean
        enable = true;
        # @type string
        pattern = ".*%.env.*";
      };

      # @class rest.Config.UI
      ui = {
        # @type boolean Whether to set winbar to result panes
        winbar = true;

        # @class rest.Config.UI.Keybinds
        keybinds = {
          # @type string Mapping for cycle to previous result pane
          prev = "H";
          # @type string Mapping for cycle to next result pane
          next = "L";
        };
      };

      # @class rest.Config.Highlight
      highlight = {
        # @type boolean Whether current request highlighting is enabled or not
        enable = true;
        # @type number Duration time of the request highlighting in milliseconds
        timeout = 750;
      };

      # @see vim.log.levels
      # @type integer log level
      _log_level = {
        __raw = "vim.log.levels.WARN";
      };
    };
  };

  programs.nixvim.keymaps = [
    {
      key = "<leader>rr";
      action = "<cmd>Rest run<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "rest.nvim - [r]est [r]un";
      };
    }
    {
      key = "<leader>rl";
      action = "<cmd>Rest run last<cr>";
      mode = "n";
      options = {
        remap = false;
        desc = "rest.nvim - [r]est run [l]ast";
      };
    }
  ];
}
