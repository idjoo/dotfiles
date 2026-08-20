{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.fzf;
in
{
  options.modules.fzf = {
    enable = mkEnableOption "fzf";
  };
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

      changeDirWidget = {
        command = "fd --type d";
        options = [
          "--preview 'ls --tree {} | head -200'"
        ];
      };

      fileWidget = {
        command = "fd --type f";
        options = [
          "--preview 'head {}'"
        ];
      };

      historyWidget = {
        # Atuin's shell integration is sourced after fzf's and already owns
        # Ctrl-R, so fzf's history binding is disabled to settle the conflict.
        # Swap to `programs.atuin.flags = [ "--disable-ctrl-r" ];` instead if
        # fzf should own Ctrl-R.
        command = "";
        options = [
          "--sort"
          "--exact"
        ];
      };

      tmux = {
        enableShellIntegration = true;
        shellIntegrationOptions = [ ];
      };
    };
  };
}
