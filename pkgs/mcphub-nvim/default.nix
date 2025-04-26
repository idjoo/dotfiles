{
  lib,
  pkgs,
  fetchFromGitHub,
}:

pkgs.vimUtils.buildVimPlugin rec {
  pname = "mcphub-nvim";
  version = "4.9.0";

  src = fetchFromGitHub {
    owner = "ravitemer";
    repo = "mcphub.nvim";
    rev = "v${version}";
    hash = "sha256-MXVpJAofowHdtRT+ae9u6lt0mDig/NRCeSoWBo67QMQ=";
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
