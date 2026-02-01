{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.opencode;

  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export ENABLE_TOOL_SEARCH=true
    export GOOGLE_APPLICATION_CREDENTIALS=${config.home.homeDirectory}/.claude/sa.json
    export GOOGLE_VERTEX_PROJECT=lv-playground-genai
    export GOOGLE_VERTEX_LOCATION=global
    export OPENCODE_DISABLE_LSP_DOWNLOAD=true
    export OPENCODE_EXPERIMENTAL=true
    exec ${pkgs.llm-agents.opencode}/bin/opencode "$@"
  '';
in
{
  options.modules.opencode = {
    enable = lib.mkEnableOption "opencode";
  };

  config = lib.mkIf cfg.enable {
    home.shellAliases = {
      oc = "${opencodeWrapper}/bin/opencode";
    };

    xdg.configFile."opencode/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/modules/home-manager/ai/opencode/AGENTS.md";

    programs.opencode = {
      enable = true;

      package = opencodeWrapper;

      enableMcpIntegration = true;

      commands = {
        commit = ./commands/commit.md;
      };

      skills = {
        tmux = ./skills/tmux;
      };

      settings = {
        model = "google-vertex-anthropic/claude-opus-4-5@20251101";
        small_model = "google-vertex-anthropic/claude-sonnet-4-5@20250929";

        # model = "moonshotai/kimi-k2.5";

        permission = {
          lsp = "allow";
          skill = "allow";
          todowrite = "allow";
          todoread = "allow";
        };

        lsp = {
          nixd = {
            command = [ "${pkgs.nixd}/bin/nixd" ];
            extensions = [ ".nix" ];
          };

          pyright = {
            command = [ "${pkgs.pyright}/bin/pyright" ];
            extensions = [
              ".py"
              ".pyi"
            ];
          };

          bqls = {
            command = [ "${config.home.homeDirectory}/.local/bin/bqls" ];
            extensions = [
              ".bqsql"
            ];
          };
        };

        compaction = {
          auto = true;
          prune = true;
        };
      };
    };
  };
}
