{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.modules.nvim;
in {
  options.modules.nvim = {enable = mkEnableOption "nvim";};
  config = mkIf cfg.enable {
    home.activation.installNvimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.rsync}/bin/rsync \
        --archive --compress \
        --verbose --chmod=D2755,F744 \
        ${./config}/ ${config.xdg.configHome}/nvim/
    '';

    programs.neovim = {
      enable = true;
      defaultEditor = true;
      extraLuaConfig = ''
        require("idjo")
      '';
    };
  };
}
