{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.git;
in {
  options.modules.git = {enable = mkEnableOption "git";};
  config = mkIf cfg.enable {
    programs.git = {
      enable = true;

      userEmail = "adrianusvian1@gmail.com";
      userName = "Adrianus Vian Habirowo";

      diff-so-fancy = {
        enable = true;
      };

      extraConfig = {
        init = {
          defaultBranch = "master";
        };
      };
    };
  };
}
