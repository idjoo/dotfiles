{
  lib,
  config,
  inputs,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.modules.cursor;
in
{
  imports = [
    inputs.cursor.homeModules.cursor
  ];

  options.modules.cursor = {
    enable = mkEnableOption "cursor";
  };

  config = mkIf cfg.enable {
    home.shellAliases = {
      ca = "${pkgs.cursor-cli}/bin/cursor-agent";
    };

    programs.cursor = {
      enable = cfg.enable;

      enableMcpIntegration = true;

      cli = {
        enable = true;

        package = pkgs.llm-agents.cursor-agent;

        settings = {
          editor = {
            vimMode = true;
          };
          display = {
            showLineNumbers = true;
          };
          permissions = {
            allow = [
              "Shell(git:*)"
              "Shell(gh:*)"
              "Shell(nix:*)"
              "Shell(nh:*)"
              "Shell(uv:*)"
              "Shell(jq:*)"
              "Shell(yq:*)"
              "Shell(rg:*)"
              "Shell(fd:*)"
              "Shell(cat:*)"
              "Shell(eza:*)"
              "Shell(wc:*)"
              "Shell(sort:*)"
              "Shell(uniq:*)"
              "Shell(diff:*)"
              "Shell(which:*)"
              "Shell(type:*)"
              "Shell(readlink:*)"
            ];
            deny = [
              "Read(.env*)"
              "Read(./secrets/**)"
            ];
          };
          attribution = {
            attributeCommitsToAgent = false;
            attributePRsToAgent = false;
          };
        };
      };

      rules = {
        workflow = ''
          ---
          description: "Task execution — plan, parallelize, verify"
          alwaysApply: true
          ---

          ### Plan first
          Call `TodoWrite` before your first action on any 2+ step task.
          - Atomic, verifiable items. One `in_progress` at a time.
          - Mark `completed` immediately when done — never batch completions.

          ### Execute efficiently
          - **Parallel calls**: Independent tool calls go in one message.
            `Read(a.ts) + Read(b.ts) + Grep("TODO")` in one turn, not three.
          - **Shell chaining**: One `Shell` call with `&&` / `;` — never split across calls.
          - **Python**: Always `uv run` — never bare `python` / `python3`.

          ### Verify before completing

          | Change | Verification |
          |--------|-------------|
          | Code | Run tests or type-check |
          | Config | Syntax check / dry-run |
          | Bug fix | Reproduce → fix → confirm gone |

          Two failures with the same approach → pivot strategy or ask the user.
        '';

        code-intelligence = ''
          ---
          description: "Navigate code with Serena, query libraries with Context7"
          alwaysApply: true
          ---

          ### Code: Serena first
          Semantic tools understand structure — prefer them over text search.

          | Goal | Tool |
          |------|------|
          | File overview | `serena-get_symbols_overview` |
          | Find definition | `serena-find_symbol` (include_body: true) |
          | Find usages | `serena-find_referencing_symbols` |
          | Regex search | `serena-search_for_pattern` |
          | Edit symbol | `serena-replace_symbol_body` |

          Use `Grep` / `Read` only for non-code files or when Serena is unavailable.

          ### Libraries: Context7 first
          Before calling any library API, query its current docs:
          1. `context7-resolve-library-id("<lib>", "<goal>")`
          2. `context7-query-docs(id, "<specific question>")`
          3. Implement from returned docs — never from training-data memory

          Skip only for purely project-internal code with no external API calls.
        '';

        communication = ''
          ---
          description: "Interaction style and scope discipline"
          alwaysApply: true
          ---

          - **Act, don't narrate.** Do the work — don't describe what you're about to do.
          - **Ask on ambiguity.** If a request has multiple valid interpretations, clarify before committing.
          - **Surface blockers.** Report errors immediately. Don't silently retry the same failed approach.
          - **Stay in scope.** Do what was asked. No unrequested refactors, no bonus features, no surprise files.
          - **Summarize at the end.** State what changed and why in 1-3 sentences.
        '';
      };
    };
  };
}
