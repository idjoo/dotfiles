{
  pkgs,
  lib,
  config,
  outputs,
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

      dotDir = "${config.xdg.configHome}/zsh";

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
          bindkey '^[^?' backward-delete-word

          bindkey "$terminfo[kcuu1]" history-substring-search-up
          bindkey "$terminfo[kcud1]" history-substring-search-down
          bindkey -M vicmd 'k' history-substring-search-up
          bindkey -M vicmd 'j' history-substring-search-down

          zstyle ':completion:*' menu select
          setopt interactivecomments

          [[ ! -z "$DISPLAY" ]] && ${pkgs.xorg.xset}/bin/xset r rate 200 50
        '';

      envExtra = # bash
        ''
          export KEYTIMEOUT=1
          export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='fg=magenta,bold'
          export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='fg=red,bold'
        '';

      setOptions = [
        "NO_AUTO_REMOVE_SLASH"
        "INTERACTIVE_COMMENTS"
      ];
    };
  };
}
