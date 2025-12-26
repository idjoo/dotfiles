{
  pkgs,
  lib,
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
          "-y"
          "@upstash/context7-mcp@latest"
        ];
      };

      gcloud = {
        command = "${pkgs.bun}/bin/bunx";
        args = [
          "-y"
          "@google-cloud/gcloud-mcp@latest"
        ];
      };
    };
  };
}
