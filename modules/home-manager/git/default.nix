{ lib
, config
, ...
}:
with lib; let
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

      userName = "Adrianus Vian Habirowo";
      userEmail = cfg.email;

      diff-so-fancy = {
        enable = true;
      };

      extraConfig = {
        init = {
          defaultBranch = "master";
        };

        pull = {
          rebase = true;
        };
      };
    };
  };
}
