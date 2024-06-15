{ pkgs
, lib
, config
, ...
}:
with lib; let
  cfg = config.modules.tmux;
in
{
  options.modules.tmux = { enable = mkEnableOption "tmux"; };
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = cfg.enable;

      disableConfirmationPrompt = true;
      historyLimit = 999999999;
      keyMode = "vi";
      mouse = true;
      newSession = false;
      prefix = "M-f";
      resizeAmount = 5;
      sensibleOnTop = false;
      shell = "${pkgs.zsh}/bin/zsh";

      plugins = [
        {
          plugin = pkgs.tmuxPlugins.resurrect;
          extraConfig = ''
            set -g @resurrect-strategy-nvim 'session'
            set -g @resurrect-capture-pane-contents 'on'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-boot 'on'
            set -g @continuum-save-interval '5'
          '';
        }
        {
          plugin = pkgs.tmuxPlugins.pain-control;
        }
      ];

      extraConfig = ''
        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        # ---------------------
        set -g default-terminal "xterm-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set-environment -g COLORTERM "truecolor"

        unbind-key -T copy-mode-vi v
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
        bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe "xsel -i -p && xsel -o -p | xsel -i -b"
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x

        # windows titles
        # ---------------------
        set -g set-titles on
        set -g set-titles-string '#T'

        # status bar
        # ---------------------
        set -g status-left ""
        set -g status-right '#(date +" %H:%M ")'
        set -g window-status-format '#I #W'
        set -g window-status-current-format ' #I #W '

        # reload config
        # ---------------------
        bind r source-file ~/.config/tmux/tmux.conf\; display "Config reloaded"

        # sync pane
        # ---------------------
        unbind s
        bind s set-window-option synchronize-panes\; display-message "synchronize-panes #{?pane_synchronized,on,off}"
      '';
    };
  };
}
