{
  programs.nixvim.plugins.codecompanion = {
    enable = true;

    settings = {
      adapters = {
        vertex = {
          __raw = # lua
            ''
              function()
                return require("codecompanion.adapters").extend("gemini", {
                  url = "https://us-central1-aiplatform.googleapis.com/v1/projects/lv-playground-genai/locations/us-central1/endpoints/openapi/chat/completions",
                  env = {
                    api_key = "GEMINI_API_KEY",
                  },
                  schema = {
                    model = {
                      default = "google/gemini-2.0-flash",
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
          adapter = "vertex";
        };
        chat = {
          adapter = "vertex";
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
