{ config, pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.mcphub-nvim ];
    extraConfigLuaPre = # lua
      ''
        require("mcphub").setup({
          port = 3000,
          config = vim.fn.expand("${config.home.homeDirectory}/.config/mcphub/servers.json"),
          cmd = "${pkgs.mcp-hub}/bin/mcp-hub",

          auto_approve = true,
          auto_toggle_mcp_servers = true,

          extensions = {
            avante = {
              enabled = true,
              make_slash_commands = true,
            },

            codecompanion = {
              show_result_in_chat = true,
              make_vars = true,
              make_slash_commands = true,
            },
          },

          log = {
            level = vim.log.levels.WARN,
            to_file = false,
            file_path = nil,
            prefix = "MCPHub",
          },
        })
      '';
  };

  home = {
    file =
      let
        mcpServers = # json
          ''
            {
              "mcpServers": {
                "smartfren": {
                  "command": "${pkgs.uv}/bin/uv",
                  "args": [
                    "--directory",
                    "${config.home.homeDirectory}/documents/smartfren/chatbot/id-smartfren-ccai-mcp",
                    "run",
                    "stdio"
                  ]
                },
                "smartfren-local": {
                  "url": "http://localhost:8080/mcp/"
                },
                "smartfren-dev": {
                  "url": "https://sf-mcp-314894585051.asia-southeast2.run.app/mcp/"
                },
                "whatsapp": {
                  "command": "${pkgs.uv}/bin/uv",
                  "args": [
                    "--directory",
                    "${config.home.homeDirectory}/documents/whatsapp-mcp/whatsapp-mcp-server",
                    "run",
                    "main.py"
                  ]
                },
                "context7": {  
                  "command": "${pkgs.bun}/bin/bunx",  
                  "args": ["-y", "@upstash/context7-mcp@latest"]  
                }  
              }
            }
          '';
      in
      {
        ".config/mcphub/servers.json".text = mcpServers;
        ".cursor/mcp.json".text = builtins.replaceStrings [ "/mcp" ] [ "/sse" ] mcpServers;
      };
  };
}
