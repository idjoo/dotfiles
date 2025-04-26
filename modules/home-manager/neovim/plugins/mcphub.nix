{ config, pkgs, ... }:
{
  programs.nixvim = {
    extraPlugins = [ pkgs.mcphub-nvim ];
    extraConfigLua = ''
      require("mcphub").setup({
        port = 3000,
        config = vim.fn.expand("${config.home.homeDirectory}/.config/mcphub/servers.json"),
        cmd = "${pkgs.mcp-hub}/bin/mcp-hub",
      })
    '';
  };

  home = {
    file = {
      ".config/mcphub/servers.json".text = # json
        ''
          {
            "mcpServers": {
              "whatsapp": {
                "command": "${pkgs.uv}/bin/uv",
                "args": [
                  "--directory",
                  "${config.home.homeDirectory}/documents/whatsapp-mcp/whatsapp-mcp-server",
                  "run",
                  "main.py"
                ]
              },
              "bigquery": {
                "command": "${pkgs.uv}/bin/uvx",
                "args": [
                  "mcp-server-bigquery",
                  "--project",
                  "smartfren-analytic-dev",
                  "--location",
                  "asia-southeast2"
                ]
              }
            }
          }
        '';
    };
  };
}
