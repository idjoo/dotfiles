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
          "-y"
          "@upstash/context7-mcp@latest"
        ];
      };

      tmux = {
        command = "${pkgs.bun}/bin/bunx";
        args = [
          "-y"
          "tmux-mcp"
          "--shell-type=zsh"
        ];
      };

      playwright = {
        command = "docker";
        args = [
          "run"
          "--interactive"
          "--rm"
          "--init"
          "--pull=always"
          "--volume=${config.home.homeDirectory}/.playwright:/playwright-data"
          "mcr.microsoft.com/playwright/mcp"
          "--output-dir=/playwright-data"
          "--storage-state=/playwright-data/state.json"
        ];
      };
    };
  };
}
