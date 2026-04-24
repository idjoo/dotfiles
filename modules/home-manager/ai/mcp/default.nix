{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
{
  home.packages = [
    pkgs.marksman
    pkgs.ruby-lsp
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

      drawio = {
        command = "${pkgs.bun}/bin/bunx";
        args = [
          "@next-ai-drawio/mcp-server@latest"
        ];
      };
    };
  };
}
