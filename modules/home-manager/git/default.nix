{
  lib,
  config,
  ...
}:
with lib;
let
  cfg = config.modules.git;
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
    programs.git = {
      enable = cfg.enable;

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
