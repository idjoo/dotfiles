{ config, pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.mcphub-nvim ];
    extraConfigLuaPre = # lua
      ''
        require("mcphub").setup({
          port = 3000,
          config = vim.fn.expand("${config.xdg.configHome}/mcphub/servers.json"),
          cmd = "${pkgs.mcp-hub}/bin/mcp-hub",
          log = {
            level = vim.log.levels.WARN,
            to_file = false,
            file_path = nil,
            prefix = "MCPHub",
          },
        })
      '';
  };

  home =
    let
      mcpServers = # json
        ''
          {
            "mcpServers": {
              "context7": {
                "command": "${pkgs.bun}/bin/bunx",
                "args": [
                  "-y",
                  "@upstash/context7-mcp@latest"
                ]
              }
            }
          }
        '';
    in
    {
      file = {
        "${config.xdg.configHome}/mcphub/servers.json".text = mcpServers;
        "${config.home.homeDirectory}/.cursor/mcp.json".text =
          builtins.replaceStrings [ "/mcp" ] [ "/sse" ]
            mcpServers;
      };

      activation = {
        updateGeminiSettings = config.lib.dag.entryAfter [ "writeBoundary" ] ''
          set -e
          settings_file="${config.home.homeDirectory}/.gemini/settings.json"
          mcp_servers_json='${mcpServers}'
          mkdir -p "$(${pkgs.coreutils}/bin/dirname "$settings_file")"
          if [ ! -f "$settings_file" ] || [ ! -s "$settings_file" ]; then
            echo "{}" > "$settings_file"
          fi
          temp_file=$(${pkgs.coreutils}/bin/mktemp)
          trap '${pkgs.coreutils}/bin/rm -f "$temp_file"' EXIT
          if ${pkgs.jq}/bin/jq \
            --argjson mcp_servers "$mcp_servers_json" \
            '.mcpServers = $mcp_servers.mcpServers' \
            "$settings_file" > "$temp_file";
          then
            ${pkgs.coreutils}/bin/mv "$temp_file" "$settings_file"
          else
            echo "Failed to update gemini settings with jq" >&2
            exit 1
          fi
        '';
      };
    };
}
