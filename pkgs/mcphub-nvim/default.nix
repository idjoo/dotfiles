{
  lib,
  pkgs,
  fetchFromGitHub,
}:

pkgs.vimUtils.buildVimPlugin rec {
  pname = "mcphub-nvim";
  version = "5.4.0";

  src = fetchFromGitHub {
    owner = "ravitemer";
    repo = "mcphub.nvim";
    rev = "v${version}";
    hash = "sha256-XOnlLgK67mOzAdm+Y+8oR6TY9q7EvUT7MQfk3fLKAqM=";
  };

  meta = {
    description = "A powerful Neovim plugin for managing MCP (Model Context Protocol) servers";
    homepage = "https://github.com/ravitemer/mcphub.nvim";
    changelog = "https://github.com/ravitemer/mcphub.nvim/blob/${src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "mcphub-nvim";
    platforms = lib.platforms.all;
  };

  dependencies = [
    pkgs.mcp-hub
    pkgs.vimPlugins.plenary-nvim
    pkgs.vimPlugins.codecompanion-nvim
    pkgs.vimPlugins.lualine-nvim
  ];

  nvimSkipModules = [
    "bundled_build"
  ];
}
