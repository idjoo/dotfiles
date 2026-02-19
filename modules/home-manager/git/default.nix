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
        ".serena/"
        ".direnv/"
        "*.db"
        "*.sqlite"
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
      };
    };

    programs.diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}
