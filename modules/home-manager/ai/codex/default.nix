{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.codex;
in
{
  options.modules.codex = {
    enable = mkEnableOption "codex";
  };

  config = mkIf cfg.enable {
    # Allow replacing an existing writable config.toml during switch.
    home.file.".codex/config.toml".force = true;

    home.shellAliases = {
      co = "codex";
    };

    programs.codex = {
      enable = true;

      package = pkgs.llm-agents.codex;

      enableMcpIntegration = false;

      context = ./AGENTS.md;

      settings = {
        model = "gpt-5.4-mini";
        model_reasoning_effort = "high";
        plan_mode_model = "gpt-5.3-codex";
        plan_mode_reasoning_effort = "high";
        model_provider = "openai";
        model_providers = {
          azure_cognitive_service = {
            name = "Azure Cognitive Service";
            base_url = "https://pauls-mji03ow6-eastus2.cognitiveservices.azure.com/openai/v1";
            env_key = "AZURE_OPENAI_API_KEY";
            wire_api = "responses";
          };
        };

        approval_policy = "never";
        sandbox_mode = "danger-full-access";

        feedback = {
          enabled = false;
        };

        personality = "pragmatic";

        check_for_update_on_startup = false;

        commit_attribution = "";

        features = {
          fast_mode = false;
          undo = true;
        };

        hide_agent_reasoning = false;

        model_reasoning_summary = "auto";

        # Mark this workspace as trusted to suppress trust prompt.
        projects = {
          "/home/idjo/dotfiles" = {
            trust_level = "trusted";
          };
        };

        # Pre-ack model migration notice so startup does not prompt.
        notice = {
          model_migrations = {
            "gpt-5.3-codex" = "gpt-5.4";
          };
        };

        marketplaces = {
          stitch-skills = {
            source_type = "local";
            source = "${inputs.stitch-skills}";
          };
        };

        plugins = {
          "superpowers@openai-curated" = {
            enabled = true;
          };
          "stitch-design@stitch-skills" = {
            enabled = true;
          };
          "stitch-build@stitch-skills" = {
            enabled = true;
          };
          "stitch-utilities@stitch-skills" = {
            enabled = true;
          };
        };
      };
    };

    # Keep config writable: codex persists small prompt preferences there.
    home.activation.codexWritableConfig = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      cfg="$HOME/.codex/config.toml"
      if [ -L "$cfg" ]; then
        tmp="$(mktemp)"
        cp --dereference "$cfg" "$tmp"
        rm -f "$cfg"
        mv "$tmp" "$cfg"
        chmod 600 "$cfg"
      fi
    '';
  };
}
