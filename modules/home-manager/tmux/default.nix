{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.tmux;
in {
  options.modules.tmux = {enable = mkEnableOption "tmux";};
  config = mkIf cfg.enable {
    programs.tmux = {
      enable = true;
      historyLimit = 999999999;
      keyMode = "vi";
      newSession = false;
      prefix = "M-f";
      resizeAmount = 5;
      shell = "${pkgs.zsh}/bin/zsh";
      terminal = "xterm-256color";
      sensibleOnTop = false;
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
        unbind-key -T copy-mode-vi v
        bind-key -T copy-mode-vi 'v' send -X begin-selection
        bind-key -T copy-mode-vi 'C-v' send -X rectangle-toggle
        bind-key -T copy-mode-vi 'y' send-keys -X copy-pipe "xsel -i -p && xsel -o -p | xsel -i -b"
        # bind-key 'p' run "xsel -o | tmux load-buffer - ; tmux paste-buffer"
        bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-selection -x

        # windows titles
        # ---------------------
        set -g set-titles on
        set -g set-titles-string '#T'

        # set escape time
        # ---------------------
        set-option -sg escape-time 0
        set-option -g focus-events on

        # status bar
        # ---------------------
        set -g status-bg '#1f281f'
        set -g status-fg '#ffffff'
        set -g status-left ""
        set -g status-right '#{continuum_status}m #[bg=#435643]#[fg=#ffffff]#(date +" %H:%M ")'
        set -g window-status-format '#I #W'
        set -g window-status-current-format ' #I #W '
        setw -g window-status-current-style bg='#435643',fg='#a4cc78'

        # pane border colors
        # ---------------------
        set -g pane-active-border-style fg='#a4cc78'
        set -g pane-border-style fg='#555555'

        # reload config
        # ---------------------
        bind r source-file ~/.config/tmux/tmux.conf\; display "Config reloaded"

        # sync pane
        # ---------------------
        unbind s
        bind s set-window-option synchronize-panes\; display-message "synchronize-panes #{?pane_synchronized,on,off}"

        # split pane
        # ---------------------
        unbind '"'
        unbind %
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
      '';
    };
  };
}
