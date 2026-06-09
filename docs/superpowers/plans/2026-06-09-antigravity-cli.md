# Antigravity CLI Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the repo's Gemini CLI module identity with a clean Antigravity CLI module, while keeping the existing Home Manager Antigravity configuration working.

**Architecture:** The migration keeps one local Home Manager module under `modules/home-manager/ai/antigravity-cli/` and one aggregate toggle under `modules.ai.antigravity-cli`. The module continues to configure `programs.antigravity-cli`, but it stops pinning the Gemini package, stops defining a `gemini` alias, and uses native Home Manager Antigravity options for context files and MCP integration.

**Tech Stack:** Nix flakes, Home Manager modules, ripgrep, git, beads (`br`)

---

## File Structure

- `modules/home-manager/ai/antigravity-cli/default.nix`
  Local Antigravity CLI Home Manager module. Owns the repo-facing option namespace `modules.antigravity-cli` and renders `programs.antigravity-cli`.
- `modules/home-manager/ai/antigravity-cli/AGENTS.md`
  Repo-managed context source for Antigravity CLI.
- `modules/home-manager/ai/default.nix`
  Aggregate AI module that imports submodules and exposes `modules.ai.*` toggles.
- `modules/home-manager/ai/skills/default.nix`
  Skills configuration listing default agent IDs. Since the current `skills.nix` input does not expose an obvious Antigravity agent identifier, this migration removes the Gemini-specific entry instead of replacing it with a guessed value.
- `README.md`
  User-facing module category table.
- `docs/MODULES.md`
  Module reference page.
- `docs/AI-MCP-ARCHITECTURE.md`
  AI module overview and usage example.
- `docs/ARCHITECTURE.md`
  Mermaid architecture diagram that shows the AI module directories.

### Task 1: Rename the local module and convert it to Antigravity-native options

**Files:**
- Create: `modules/home-manager/ai/antigravity-cli/default.nix`
- Create: `modules/home-manager/ai/antigravity-cli/AGENTS.md`
- Delete: `modules/home-manager/ai/gemini-cli/default.nix`
- Delete: `modules/home-manager/ai/gemini-cli/GEMINI.md`

- [ ] **Step 1: Capture the pre-migration baseline**

Run:

```bash
rg -n "modules\\.gemini-cli|pkgs\\.gemini-cli|GEMINI\\.md|home\\.file\\.\"\\.gemini/GEMINI\\.md\"|gemini = ''" modules/home-manager/ai/gemini-cli/default.nix
```

Expected: multiple matches showing the old Gemini-branded module state.

- [ ] **Step 2: Rename the module directory and context file**

Run:

```bash
mv modules/home-manager/ai/gemini-cli modules/home-manager/ai/antigravity-cli
mv modules/home-manager/ai/antigravity-cli/GEMINI.md modules/home-manager/ai/antigravity-cli/AGENTS.md
```

Expected: both `mv` commands exit with status `0`.

- [ ] **Step 3: Rewrite the local module around `modules.antigravity-cli`**

Write `modules/home-manager/ai/antigravity-cli/default.nix` so the top-level shape matches this pattern:

```nix
{
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.antigravity-cli;
in
{
  options.modules.antigravity-cli = {
    enable = mkEnableOption "antigravity-cli";
  };

  imports = [
    inputs.sops-nix.homeManagerModules.sops
  ];

  config = mkIf cfg.enable {
    programs.antigravity-cli = {
      enable = true;
      enableMcpIntegration = true;

      context = {
        AGENTS = ./AGENTS.md;
      };

      commands = {
        context = {
          prompt = ''
            <PERSONA>
            You are a Senior Technical Writer's assistant and a Documentation Architect. You specialize in analyzing complex codebases and synthesizing them into clear, high-level architectural summaries optimized for AI consumption.
            </PERSONA>

            <OBJECTIVE>
            Your task is to analyze the provided codebase context and generate a structured summary that explains the ARCHITECTURE, DATA FLOW, and PURPOSE of the code. This summary will be used by other AI agents to understand the system quickly.
            </OBJECTIVE>

            <INSTRUCTIONS>
            1.  **Analyze the Context:** Read the provided file structure, file contents, and logic in the input.
                Context Input:
                ```
                {{args}}
                ```
            2.  **Synthesize Information:** Identify the core purpose, the organization of files, the key classes/functions, and how data moves through the system.
            3.  **Format Output:** detailed in the <OUTPUT> section.
            </INSTRUCTIONS>

            <CRITICAL_CONSTRAINTS>
            -   **No Raw Code:** Do not output code blocks unless necessary for specific config examples.
            -   **High-Level & Accurate:** Balance brevity with technical depth.
            -   **AI-Optimized:** The output must be structured so another AI can parse it easily.
            </CRITICAL_CONSTRAINTS>

            <OUTPUT>
            Generate a Markdown response following this exact structure:

            1.  **Project Overview:** 1-2 sentences on what this module does.
            2.  **File Structure:** Briefly explain the organization of the files provided.
            3.  **Key Components:** List main classes/functions and their responsibilities.
            4.  **Logic Flow:** Explain the data lifecycle (Inputs -> Processing -> Outputs).
            </OUTPUT>
          '';
          description = "Context summarization generator";
        };
      };

      settings = {
        context = {
          fileName = [ "AGENTS.md" ];
          loadMemoryFromIncludeDirectories = true;
        };

        general = {
          previewFeatures = true;
          preferredEditor = "neovim";
          vimMode = true;
          disableAutoUpdate = true;
          disableUpdateNag = true;
          checkpointing.enabled = true;
          enablePromptCompletion = true;
          retryFetchErrors = false;
          debugKeystrokeLogging = false;
          sessionRetention = {
            enabled = true;
            maxAge = "30d";
            maxCount = 88;
            minRetention = "1d";
          };
        };

        output.format = "text";
        ui = {
          customThemes = { };
          hideWindowTitle = false;
          showStatusInTitle = true;
          hideTips = true;
          hideBanner = true;
          hideContextSummary = false;
          footer = {
            hideCWD = false;
            hideSandboxStatus = true;
            hideModelInfo = false;
            hideContextPercentage = false;
          };
          hideFooter = false;
          showMemoryUsage = true;
          showLineNumbers = true;
          showCitations = true;
          showModelInfoInChat = false;
          customWittyPhrases = [
            "Nanem Peju"
            "Ngulum Kontol"
            "Nyepongin Kontol"
            "Jilatin Memek"
            "Peras Tete"
          ];
          accessibility = {
            disableLoadingPhrases = false;
            screenReader = false;
          };
        };
        privacy.usageStatisticsEnabled = false;
        model = {
          name = "gemini-3-flash-preview";
          compressionThreshold = 0.75;
        };
        security = {
          enablePermanentToolApproval = true;
          auth.selectedType = "vertex-ai";
        };
        tools = {
          shell.showColor = true;
          useRipgrep = true;
          autoAccept = true;
          allowed = [ "run_shell_command(git)" ];
          exclude = [ "save_memory" ];
        };
        experimental = {
          enableAgents = true;
          extensionManagement = true;
          extensionReloading = true;
          jitContext = true;
          codebaseInvestigatorSettings.enabled = true;
          introspectionAgentSettings.enabled = true;
          skills = true;
        };
      };
    };
  };
}
```

Key implementation rules:

- Remove `pkgs` from the parameter list if it is no longer used.
- Remove the manual `home.file.".gemini/GEMINI.md"` symlink.
- Remove the `home.shellAliases.gemini` entry.
- Do not set `package = pkgs.gemini-cli`.
- Preserve the current `commands.context.prompt` body and the current UI settings unless they depend on Gemini naming.

- [ ] **Step 4: Verify the old Gemini-specific implementation hooks are gone**

Run:

```bash
rg -n "pkgs\\.gemini-cli|home\\.file\\.\"\\.gemini/GEMINI\\.md\"|gemini = ''" modules/home-manager/ai/antigravity-cli/default.nix
```

Expected: no matches.

- [ ] **Step 5: Commit the module rename and rewrite**

Run:

```bash
git add modules/home-manager/ai/antigravity-cli
git commit -m "refactor(ai): ♻️ rename gemini-cli module to antigravity-cli"
```

Expected: one commit containing the renamed module directory and the rewritten local module.

### Task 2: Rewire aggregate module options and skills defaults

**Files:**
- Modify: `modules/home-manager/ai/default.nix`
- Modify: `modules/home-manager/ai/skills/default.nix`

- [ ] **Step 1: Capture the failing aggregate references**

Run:

```bash
rg -n "gemini-cli" modules/home-manager/ai/default.nix modules/home-manager/ai/skills/default.nix
```

Expected: matches in the import list, module descriptions, toggle name, default wiring, and skills default agent list.

- [ ] **Step 2: Update the aggregate AI module to Antigravity naming**

Edit `modules/home-manager/ai/default.nix` so the relevant sections look like this:

```nix
  imports = [
    ./claude-code
    ./codex
    ./antigravity-cli
    ./mcp
    ./opencode
    ./skills
  ];

  options.modules.ai = {
    enable = mkEnableOption "AI tools (claude-code, codex, antigravity-cli, opencode, mcp)";

    antigravity-cli = mkOption {
      type = types.bool;
      default = cfg.enable;
      description = "Enable antigravity-cli when ai.enable is true";
    };
  };

  config = {
    modules = {
      antigravity-cli.enable = mkDefault cfg.antigravity-cli;
    };
  };
```

Remove the old `gemini-cli` option and default mapping completely.

- [ ] **Step 3: Remove the Gemini-specific skills agent entry**

Edit `modules/home-manager/ai/skills/default.nix` so the `defaultAgents` list drops `gemini-cli` entirely:

```nix
      defaultAgents = [
        "opencode"
        "claude-code"
        "codex"
      ];
```

Do not add a guessed Antigravity agent ID here. The migration goal for this file is to remove the Gemini-specific default.

- [ ] **Step 4: Verify the AI module tree no longer uses the old module name**

Run:

```bash
rg -n "modules\\.ai\\.gemini-cli|modules\\.gemini-cli|./gemini-cli|\"gemini-cli\"" modules/home-manager/ai
```

Expected: no matches.

- [ ] **Step 5: Commit the option rewiring**

Run:

```bash
git add modules/home-manager/ai/default.nix modules/home-manager/ai/skills/default.nix
git commit -m "refactor(ai): ♻️ rewire ai toggles for antigravity-cli"
```

Expected: one commit containing the aggregate option rename and the skills default-agent update.

### Task 3: Remove stale Gemini references from user-facing docs

**Files:**
- Modify: `README.md`
- Modify: `docs/MODULES.md`
- Modify: `docs/AI-MCP-ARCHITECTURE.md`
- Modify: `docs/ARCHITECTURE.md`

- [ ] **Step 1: Capture the failing doc references**

Run:

```bash
rg -n "gemini-cli|Gemini CLI" README.md docs/MODULES.md docs/AI-MCP-ARCHITECTURE.md docs/ARCHITECTURE.md
```

Expected: matches in the README module table, module docs, AI architecture write-up, and Mermaid diagram.

- [ ] **Step 2: Update the README and module reference pages**

Apply these content changes:

```md
| **AI** | claude-code, antigravity-cli, mcp, playwright |
```

```md
#### `modules.antigravity-cli`

Antigravity CLI tool for AI-powered assistance.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | bool | `false` | Enable Antigravity CLI |

**Location:** `modules/home-manager/ai/antigravity-cli/`
```

- [ ] **Step 3: Update the AI architecture doc and Mermaid diagram**

Apply these content changes:

```nix
modules.antigravity-cli.enable = true;
```

```md
The Antigravity CLI module provides access to Google's Antigravity CLI for AI-powered assistance.

**Location**: `modules/home-manager/ai/antigravity-cli/`
```

```mermaid
    subgraph "AI Modules"
        CC[claude-code/]
        AG[antigravity-cli/]
        MCP[mcp/]
    end
```

Also update any headings or table rows that still say `Gemini CLI` to `Antigravity CLI`.

- [ ] **Step 4: Verify user-facing docs are clean**

Run:

```bash
rg -n "gemini-cli|Gemini CLI" README.md docs/MODULES.md docs/AI-MCP-ARCHITECTURE.md docs/ARCHITECTURE.md
```

Expected: no matches.

- [ ] **Step 5: Commit the doc cleanup**

Run:

```bash
git add README.md docs/MODULES.md docs/AI-MCP-ARCHITECTURE.md docs/ARCHITECTURE.md
git commit -m "docs(ai): 📝 rename gemini-cli docs to antigravity-cli"
```

Expected: one commit containing only the user-facing documentation rename.

### Task 4: Run repo-wide verification for the migration

**Files:**
- Verify: `modules/home-manager/ai/antigravity-cli/default.nix`
- Verify: `modules/home-manager/ai/default.nix`
- Verify: `modules/home-manager/ai/skills/default.nix`
- Verify: `README.md`
- Verify: `docs/MODULES.md`
- Verify: `docs/AI-MCP-ARCHITECTURE.md`
- Verify: `docs/ARCHITECTURE.md`

- [ ] **Step 1: Verify no stale Gemini references remain in the repo-managed surfaces**

Run:

```bash
rg -n "gemini-cli|modules\\.gemini-cli|modules\\.ai\\.gemini-cli|pkgs\\.gemini-cli|GEMINI\\.md|Gemini CLI" \
  README.md \
  docs \
  modules/home-manager \
  --glob '!docs/superpowers/specs/**' \
  --glob '!docs/superpowers/plans/**'
```

Expected: no matches.

- [ ] **Step 2: Verify the old module directory is gone**

Run:

```bash
test ! -d modules/home-manager/ai/gemini-cli
```

Expected: exit status `0`.

- [ ] **Step 3: Build the active Home Manager flake target**

Run:

```bash
nix build .#homeConfigurations.\"idjo@dragon\".activationPackage
```

Expected: successful build with no option-resolution errors for `modules.ai.antigravity-cli` or `modules.antigravity-cli`.

- [ ] **Step 4: Verify the new config path evaluates**

Run:

```bash
nix eval --json .#homeConfigurations.\"idjo@dragon\".config.modules.ai.antigravity-cli
```

Expected: `true` or `false`, proving the new config path exists and evaluates.

- [ ] **Step 5: Commit final verification-only adjustments if needed**

Run:

```bash
git status --short
```

Expected: clean working tree. If verification required tiny follow-up fixes, commit them with:

```bash
git add modules/home-manager/ai/default.nix \
  modules/home-manager/ai/skills/default.nix \
  modules/home-manager/ai/antigravity-cli/default.nix \
  README.md \
  docs/MODULES.md \
  docs/AI-MCP-ARCHITECTURE.md \
  docs/ARCHITECTURE.md
git commit -m "fix(ai): 🐛 resolve antigravity-cli migration verification issues"
```
