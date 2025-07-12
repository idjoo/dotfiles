{
  programs.nixvim.plugins.codecompanion = {
    enable = true;

    settings = {
      adapters = {
        gemini = {
          __raw = # lua
            ''
              function()
                return require("codecompanion.adapters").extend("gemini", {
                  env = {
                    api_key = "cmd:pass google.com/adrianus.vian.habirowo@gws-id.one | grep -oP 'aistudio-api-key: \\K.*'",
                  },
                  schema = {
                    model = {
                      default = "gemini-2.5-flash",
                    },
                  },
                })
              end
            '';
        };
      };
      opts = {
        log_level = "TRACE";
        send_code = true;
        use_default_actions = true;
        use_default_prompts = true;
      };
      strategies = {
        agent = {
          adapter = "gemini";
        };
        chat = {
          adapter = "gemini";
          tools = {
            __raw = # lua
              ''
                {
                  ["mcp"] = {
                    -- calling it in a function would prevent mcphub from being loaded before it's needed
                    callback = function() return require("mcphub.extensions.codecompanion") end,
                    description = "Call tools and resources from the MCP Servers",
                  }
                }
              '';
          };
        };
        inline = {
          adapter = "vertex";
        };
      };
    };
  };
}
