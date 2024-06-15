{ lib
, config
, ...
}:
with lib; let
  cfg = config.modules.fzf;
in
{
  options.modules.fzf = { enable = mkEnableOption "fzf"; };
  config = mkIf cfg.enable {
    programs.fzf = {
      enable = cfg.enable;

      colors = {
        bg = "#${config.lib.stylix.colors.base00}";
        "bg+" = "#${config.lib.stylix.colors.base01}";
      };

      defaultCommand = "fd --type f";
      defaultOptions = [
      ];

      changeDirWidgetCommand = "fd --type d";
      changeDirWidgetOptions = [
        "--preview 'tree -C {} | head -200'"
      ];

      fileWidgetCommand = "fd --type f";
      fileWidgetOptions = [
        "--preview 'head {}'"
      ];

      historyWidgetOptions = [
        "--sort"
        "--exact"
      ];

      tmux = {
        enableShellIntegration = true;
        shellIntegrationOptions = [ ];
      };
    };
  };
}
