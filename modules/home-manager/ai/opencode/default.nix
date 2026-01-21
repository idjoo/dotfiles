{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.opencode;

  oc = pkgs.writeShellScriptBin "oc" ''
    export GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json
    export GOOGLE_CLOUD_PROJECT=lv-playground-genai
    export VERTEX_LOCATION=global
    export OPENCODE_EXPERIMENTAL=true
    exec ${pkgs.opencode}/bin/opencode "$@"
  '';
in
{
  options.modules.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ oc ];

    xdg.configFile."opencode/AGENTS.md".source = ./AGENTS.md;

    programs.opencode = {
      enable = true;

      enableMcpIntegration = true;

      settings = {
        model = "vertex/claude-opus-4-5@20251101";
        permission = {
          lsp = "allow";
          skill = "allow";
        };
        lsp = {
          nixd = {
            command = [ "${pkgs.nixd}/bin/nixd" ];
            extensions = [ ".nix" ];
          };
        };
        command = {
          commit = import ./commands/commit.nix;
        };
      };
    };
  };
}
