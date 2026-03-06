{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.git;

  gw = pkgs.writers.writeBashBin "gw" ''
    if [ -z "$1" ]; then
      echo "Usage: gw <branch-name>"
      echo "Example: gw feat/new-feature"
      exit 1
    fi

    branch="$1"
    dir="../''${branch//\//-}"

    git worktree add -b "$branch" "$dir"
  '';
in
{
  options.modules.git = {
    enable = mkEnableOption "git";
    email = mkOption {
      type = lib.types.str;
      default = "";
      example = "vian@idjo.cc";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ gw ];

    programs.git = {
      enable = cfg.enable;

      ignores = [
        ".direnv/"
        "*.db"
        ".claude/settings.local.json"
        ".beads/"
        ".serena/"
        ".slim/"
        ".opencode/plans/*.md"
        ".DS_Store"
      ];

      settings = {
        user = {
          name = "Adrianus Vian Habirowo";
          email = cfg.email;
        };

        init = {
          defaultBranch = "master";
        };

        pull = {
          rebase = true;
        };

        url."git@paulsjob.ai:hyrdrocks/".insteadOf = "git@paulsjob.ai:";
        url."git@paulsjob.ai:vian-paulsjob/".insteadOf = "git@vian.paulsjob.ai:";
      };
    };

    programs.ssh = {
      enable = true;
      matchBlocks."paulsjob.ai" = {
        host = "paulsjob.ai";
        hostname = "github.com";
        identityFile = "~/.ssh/paulsjob";
        identitiesOnly = true;
      };
      matchBlocks."vian.paulsjob.ai" = {
        host = "vian.paulsjob.ai";
        hostname = "github.com";
        identityFile = "~/.ssh/paulsjob";
        identitiesOnly = true;
      };
    };

    programs.diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
