{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  playwrightDataDir = "${config.home.homeDirectory}/.playwright";
in
{
  programs.mcp = {
    enable = true;

    servers = {
      context7 = {
        command = "${pkgs.bun}/bin/bunx";
        args = [
          "@upstash/context7-mcp@latest"
        ];
      };

      serena = {
        command = "${pkgs.uv}/bin/uvx";
        args = [
          "--from=git+https://github.com/oraios/serena"
          "serena"
          "start-mcp-server"
          "--open-web-dashboard=false"
          "--context=claude-code"
          "--project-from-cwd"
        ];
      };

      atlassian = {
        url = "https://mcp.atlassian.com/v1/mcp";
      };

      playwright = mkIf config.modules.playwright.enable {
        command = "${pkgs.playwright-mcp}/bin/mcp-server-playwright";
        args = [
          "--output-dir=${playwrightDataDir}"
          "--storage-state=${playwrightDataDir}/state.json"
        ];
      };
    };
  };
}
