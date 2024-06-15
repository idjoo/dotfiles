{ lib
, config
, inputs
, ...
}:
with lib; let
  cfg = config.modules.neovim;
in
{
  imports = [
    inputs.nixvim.homeManagerModules.nixvim
    ./autocommands.nix
    ./options.nix
    ./keymaps.nix
    ./plugins
  ];

  options. modules. neovim = {
    enable = mkEnableOption "neovim";
  };

  config = mkIf cfg.enable {
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
