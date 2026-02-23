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
      oc = "opencode";
    };

    home.packages = with pkgs; [
      wakatime-cli
    ];

    xdg.configFile."opencode/opencode-ntfy.jsonc".text = builtins.toJSON {
      topic = "idjo-opencode";
    };

    xdg.configFile."opencode/supermemory.jsonc".text = builtins.toJSON {
      apiKey = 0.80;
    };

    programs.opencode = {
      enable = true;

      package = opencodeWrapper;

      enableMcpIntegration = true;

      rules = ./AGENTS.md;

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
        model = "google-vertex/gemini-3.1-pro-preview";
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
          reserved = 850000;
        };

        plugin = [
          "opencode-ntfy@latest"
          "opencode-supermemory@latest"
          "opencode-wakatime@latest"
        ];

        snapshot = true;

        share = "manual";
      };
    };
  };
}
