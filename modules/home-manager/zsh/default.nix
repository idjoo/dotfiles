{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.zsh;
in
{
  options.modules.zsh = {
    enable = mkEnableOption "zsh";
  };
  config = mkIf cfg.enable {
    home.shell.enableZshIntegration = true;

    programs.zsh = {
      enable = cfg.enable;

      dotDir = ".config/zsh";

      autocd = true;
      defaultKeymap = "viins";
      enableCompletion = true;
      enableVteIntegration = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreAllDups = true;
        ignoreSpace = true;
        path = "${config.xdg.dataHome}/zsh/history";
        share = true;
      };

      shellAliases = {
        reload = "source $ZDOTDIR/.zshrc";
        rebuild = "${pkgs.nh}/bin/nh os switch";
        n = "nvim ${config.home.homeDirectory}/note.md";
        c = "${pkgs.libqalculate}/bin/qalc";
        vim = "nvim";

        # git
        lg = "lazygit";

        # nix
        nix-shell = "${pkgs.nix-output-monitor}/bin/nom-shell --command zsh";

        # work
        spindo-dev-dashboard = ''xdg-open "https://console.cloud.google.com/monitoring/dashboards/builder/afa6b769-7933-4f81-9d52-7735bfcb79a9;startTime=$(date -u -d yesterday +"%Y-%m-%dT10:30:00Z");endTime=$(date -u +"%Y-%m-%dT10:30:00Z")?project=prj-sap-dev-398404"'';
        spindo-prod-dashboard = ''xdg-open "https://console.cloud.google.com/monitoring/dashboards/builder/5deb3680-dcd5-4a70-8749-c84dfd2efcd3;startTime=$(date -u -d yesterday +"%Y-%m-%dT10:30:00Z");endTime=$(date -u +"%Y-%m-%dT10:30:00Z")?project=prj-sap-prod-398404"'';
        spindo-dev-snapshot = ''xdg-open "https://console.cloud.google.com/compute/snapshots?referrer=search&project=prj-sap-dev-398404&pageState=(%22snapshots%22:(%22s%22:%5B(%22i%22:%22creationTimestamp%22,%22s%22:%221%22),(%22i%22:%22name%22,%22s%22:%220%22)%5D))"'';
        spindo-prod-snapshot = ''xdg-open "https://console.cloud.google.com/compute/snapshots?referrer=search&project=prj-sap-prod-398404&pageState=(%22snapshots%22:(%22s%22:%5B(%22i%22:%22creationTimestamp%22,%22s%22:%221%22),(%22i%22:%22name%22,%22s%22:%220%22)%5D))"'';

        mount-gdrive = ''${pkgs.rclone} mount gdrive:/ ~/documents/drive'';

        # k8s
        kc = "${pkgs.kubectx}/bin/kubectx";
        kn = "${pkgs.kubectx}/bin/kubens";

        # gcloud
        gp = "gcloud projects list --format='value(projectId)' | ${pkgs.fzf}/bin/fzf --height=25% --layout=reverse --border | xargs -r gcloud config set project";
        ga = "gcloud auth list --format='value(account)' | ${pkgs.fzf}/bin/fzf --height=25% --layout=reverse --border | xargs -r gcloud config set account";

        # tmux
        t = "${pkgs.tmux}/bin/tmux";
        tn = "${pkgs.tmux}/bin/tmux new";
        ta = "${pkgs.tmux}/bin/tmux attach";
      };

      plugins = [
        {
          name = "powerlevel10k";
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
          src = pkgs.zsh-powerlevel10k;
        }
        {
          name = "powerlevel10k-config";
          file = "p10k.zsh";
          src = ./.;
        }

        {
          name = "kubectl-aliases";
          file = ".kubectl_aliases";
          src = pkgs.fetchFromGitHub {
            owner = "ahmetb";
            repo = "kubectl-aliases";
            rev = "ac5bfb00a1b351e7d5183d4a8f325bb3b235c1bd";
            hash = "sha256-X2E0n/U8uzZ/JAsYIvPjnEQLri8A7nveMmbkOFSxO5s=";
          };
        }

        {
          name = "fzf-gcloud";
          file = "fzf-gcloud.plugin.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "mbhynes";
            repo = "fzf-gcloud";
            rev = "2b4ffb169389c5eb807f3d609a759c959f445b32";
            hash = "sha256-Kar27RlU22TiRF1oVubGY7WBRbDZDBqq08jC9co+G9w=";
          };
        }

        {
          name = "zsh-history-substring-search";
          file = "zsh-history-substring-search.zsh";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-history-substring-search";
            rev = "87ce96b1862928d84b1afe7c173316614b30e301";
            hash = "sha256-1+w0AeVJtu1EK5iNVwk3loenFuIyVlQmlw8TWliHZGI=";
          };
        }
      ];

      initContent = # bash
        ''
          bindkey "^H" backward-delete-char
          bindkey "^?" backward-delete-char

          bindkey "$terminfo[kcuu1]" history-substring-search-up
          bindkey "$terminfo[kcud1]" history-substring-search-down
          bindkey -M vicmd 'k' history-substring-search-up
          bindkey -M vicmd 'j' history-substring-search-down

          zstyle ':completion:*' menu select
          setopt interactivecomments

          ${pkgs.xorg.xset}/bin/xset r rate 200 50

          ${pkgs.kitty.kitten}/bin/kitten icat --align left ~/pictures/luv-with-monkey.jpg
        '';

      envExtra = # bash
        ''
          export KEYTIMEOUT=1
          export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=magenta,bold'
          export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'
        '';
    };
  };
}
