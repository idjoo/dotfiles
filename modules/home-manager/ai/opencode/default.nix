{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:
let
  cfg = config.modules.opencode;

  opencodeWrapper = pkgs.writeShellScriptBin "opencode" ''
    export ENABLE_TOOL_SEARCH=true
    export GOOGLE_APPLICATION_CREDENTIALS=${config.sops.secrets."serviceAccounts/ai".path}
    export GOOGLE_VERTEX_PROJECT=lv-playground-genai
    export GOOGLE_VERTEX_LOCATION=global
    export OPENCODE_DISABLE_LSP_DOWNLOAD=true
    export OPENCODE_EXPERIMENTAL=true
    exec ${pkgs.llm-agents.opencode}/bin/opencode "$@"
  '';
in
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];
  options.modules.opencode = {
    enable = lib.mkEnableOption "opencode";
    web.enable = lib.mkEnableOption "opencode web UI";
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

      web = lib.mkIf cfg.web.enable {
        enable = true;
        extraArgs = [
          "--hostname"
          "0.0.0.0"
          "--port"
          "4096"
          "--cors"
          "https://opencode.wyvern-vector.ts.net"
        ];
      };

      settings = {
        model = "google-vertex-anthropic/claude-opus-4-6@default";
        small_model = "google-vertex-anthropic/claude-sonnet-4-6@default";

        permission = {
          "*" = "allow";
          external_directory = {
            "$HOME/**" = "allow";
            "/tmp/**" = "allow";
          };
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

        plugin = [
          "opencode-ntfy@latest"
          "opencode-supermemory@latest"
          "opencode-wakatime@latest"
        ];
      };
    };
  };
}
