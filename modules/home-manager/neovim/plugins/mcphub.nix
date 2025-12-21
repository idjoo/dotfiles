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
      mcpServers = {
        mcpServers = config.modules.mcp-servers.servers;
      };
      mcpServersJson = builtins.toJSON mcpServers;
    in
    {
      file = {
        "${config.xdg.configHome}/mcphub/servers.json".text = mcpServersJson;
        "${config.home.homeDirectory}/.cursor/mcp.json".text =
          builtins.replaceStrings [ "/mcp" ] [ "/sse" ]
            mcpServersJson;
      };
    };
}
