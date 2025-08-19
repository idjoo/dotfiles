{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.modules.neovim;
in
{
  imports = [
    inputs.nixvim.homeModules.nixvim

    ./autocommands.nix
    ./options.nix
    ./keymaps.nix
    ./plugins
  ];

  options.modules.neovim = {
    enable = lib.mkEnableOption "neovim";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = cfg.enable;
      defaultEditor = true;
      enableMan = true;

      clipboard = {
        register = "unnamedplus";
        providers = {
          xsel.enable = true;
        };
      };

      globals.mapleader = " ";
    };
  };
}
