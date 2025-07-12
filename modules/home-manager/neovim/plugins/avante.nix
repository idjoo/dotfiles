{
  programs.nixvim.plugins.avante = {
    enable = true;

    settings = {
      provider = "vertex";

      providers = {
        vertex = {
          endpoint = "https://us-central1-aiplatform.googleapis.com/v1/projects/lv-playground-genai/locations/us-central1/publishers/google/models";
          model = "gemini-2.5-flash";
          extra_request_body = {
            timeout = 30000;
            temperature = 0;
            max_tokens = 20480;
          };
        };
      };

      # system_prompt = {
      #   __raw = ''
      #     function()
      #       local hub = require("mcphub").get_hub_instance()
      #       return hub:get_active_servers_prompt()
      #     end
      #   '';
      # };

      custom_tools = {
        __raw = ''
          {
            require("mcphub.extensions.avante").use_mcp_tool,
            require("mcphub.extensions.avante").access_mcp_resource,
          }
        '';
      };

      disabled_tools = [
        "list_files"
        "search_files"
        "read_file"
        "create_file"
        "rename_file"
        "delete_file"
        "create_dir"
        "rename_dir"
        "delete_dir"
        "bash"
      ];
    };
  };
}
