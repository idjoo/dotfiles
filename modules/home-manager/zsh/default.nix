{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.zsh;
in {
  options.modules.zsh = {enable = mkEnableOption "zsh";};
  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;

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

      historySubstringSearch = {
        enable = true;
      };

      shellAliases = {
        reload = "source $ZDOTDIR/.zshrc";
        rebuild = "sudo nixos-rebuild switch --verbose --flake ~/nix-config#$(hostname)";
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
      ];
    };
  };
}
