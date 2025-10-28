{
  lib,
  config,
  outputs,
  ...
}:
with lib;
let
  cfg = config.modules.direnv;
in
{
  options.modules.direnv = {
    enable = mkEnableOption "direnv";
  };
  config = mkIf cfg.enable {
    programs.direnv = {
      enable = cfg.enable;

      nix-direnv.enable = cfg.enable;

      config = {
        global = {
          load_dotenv = true;
        };

        whitelist = {
          prefix = [
            "/home/${outputs.username}"
            "/Users/${outputs.username}"
          ];
        };
      };
    };
  };
}
