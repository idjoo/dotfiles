{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  options.modules.mcp-servers = {
    servers = mkOption {
      type = types.attrs;
      default = { };
      description = "Centralized MCP servers configuration";
    };
  };

  config = {
    modules.mcp-servers.servers = {
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
    };
  };
}
