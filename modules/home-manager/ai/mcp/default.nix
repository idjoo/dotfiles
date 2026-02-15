{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  home.packages = [
    pkgs.serena
    pkgs.marksman
  ];

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
        command = "${pkgs.serena}/bin/serena";
        args = [
          "start-mcp-server"
          "--open-web-dashboard=false"
          "--context=claude-code"
          "--project-from-cwd"
        ];
      };

      atlassian = {
        url = "https://mcp.atlassian.com/v1/mcp";
      };

      drawio = {
        command = "${pkgs.bun}/bin/bunx";
        args = [
          "@next-ai-drawio/mcp-server@latest"
        ];
      };
    };
  };
}
