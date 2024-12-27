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
        rebuild = "nh os switch";
        n = "nvim ~/note.md";

        # git
        lg = "lazygit";

        # nix
        nix-shell = "nom-shell --command zsh";

        # work
        spindo-dev-dashboard = ''xdg-open "https://console.cloud.google.com/monitoring/dashboards/builder/afa6b769-7933-4f81-9d52-7735bfcb79a9;startTime=$(date -u -d yesterday +"%Y-%m-%dT10:30:00Z");endTime=$(date -u +"%Y-%m-%dT10:30:00Z")?project=prj-sap-dev-398404"'';
        spindo-prod-dashboard = ''xdg-open "https://console.cloud.google.com/monitoring/dashboards/builder/5deb3680-dcd5-4a70-8749-c84dfd2efcd3;startTime=$(date -u -d yesterday +"%Y-%m-%dT10:30:00Z");endTime=$(date -u +"%Y-%m-%dT10:30:00Z")?project=prj-sap-prod-398404"'';
        spindo-dev-snapshot = ''xdg-open "https://console.cloud.google.com/compute/snapshots?referrer=search&project=prj-sap-dev-398404&pageState=(%22snapshots%22:(%22s%22:%5B(%22i%22:%22creationTimestamp%22,%22s%22:%221%22),(%22i%22:%22name%22,%22s%22:%220%22)%5D))"'';
        spindo-prod-snapshot = ''xdg-open "https://console.cloud.google.com/compute/snapshots?referrer=search&project=prj-sap-prod-398404&pageState=(%22snapshots%22:(%22s%22:%5B(%22i%22:%22creationTimestamp%22,%22s%22:%221%22),(%22i%22:%22name%22,%22s%22:%220%22)%5D))"'';

        mount-gdrive = ''rclone mount gdrive:/ ~/documents/drive'';

        # k8s
        kc = "${pkgs.kubectx}/bin/kubectx";
        kn = "${pkgs.kubectx}/bin/kubens";

        # gcloud
        gp = "gcloud config set project \$(gcloud projects list --format='value(projectId)' | ${pkgs.fzf}/bin/fzf --height=25% --layout=reverse --border)";
        ga = "gcloud config set account \$(gcloud auth list --format='value(account)' | ${pkgs.fzf}/bin/fzf --height=25% --layout=reverse --border)";
      };

      plugins = [
        {
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ../zsh;
          file = "p10k.zsh";
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
      ];

      initExtra = ''
        bindkey "^H" backward-delete-char
        bindkey "^?" backward-delete-char
        zstyle ':completion:*' menu select
        setopt interactivecomments

        ${pkgs.xorg.xset}/bin/xset r rate 200 50
      '';

      envExtra = ''
        export KEYTIMEOUT=1
      '';
    };
  };
}
