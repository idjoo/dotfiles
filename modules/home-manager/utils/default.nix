{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.utils;
in
{
  options.modules.utils = {
    enable = mkEnableOption "utils";
    cli.enable = mkEnableOption "CLI utilities";
    gui.enable = mkEnableOption "GUI utilities";
  };

  config = mkIf cfg.enable {
    home.packages =
      with pkgs;
      optionals cfg.cli.enable [
        # node
        bun
        pnpm
        nodejs

        # python
        uv

        # git
        gh

        # kubernetes
        kubectl
        skaffold
      ]
      ++ optionals cfg.gui.enable [
        # IDE
        code-cursor

        # database
        dbeaver-bin
      ];
  };
}
