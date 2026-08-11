{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.herdr;
in
{
  options.modules.herdr = {
    enable = mkEnableOption "herdr terminal multiplexer";
  };

  config = mkIf cfg.enable {
    home.packages = [ pkgs.herdr ];

    # Keybindings mirror my tmux config:
    #   prefix M-f (alt+f) · pane nav h/j/k/l · splits "|" and "-"
    #   kill-pane x · kill-window & · new/next/prev window c/n/p · reload r
    # https://herdr.dev/docs/configuration/
    xdg.configFile."herdr/config.toml".text = ''
      [keys]
      # tmux: unbind C-b; set prefix M-f
      prefix = "alt+f"

      # pane navigation (vim h/j/k/l) — tmux select-pane
      focus_pane_left = "prefix+h"
      focus_pane_down = "prefix+j"
      focus_pane_up = "prefix+k"
      focus_pane_right = "prefix+l"

      # splits — tmux pain-control: "|" side by side, "-" stacked
      split_vertical = "prefix+|"
      split_horizontal = "prefix+minus"

      # panes / tabs — tmux window bindings
      close_pane = "prefix+x"       # tmux kill-pane (x)
      new_tab = "prefix+c"          # tmux new-window (c)
      next_tab = "prefix+n"         # tmux next-window (n)
      previous_tab = "prefix+p"     # tmux previous-window (p)
      close_tab = "prefix+&"        # tmux kill-window (&)

      # copy mode — tmux vi copy-mode enter
      copy_mode = "prefix+["

      # reload config — tmux "r"; move resize-mode off "r" to avoid the clash
      reload_config = "prefix+r"
      resize_mode = "prefix+shift+r"
    '';
  };
}
