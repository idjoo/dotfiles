# Antigravity CLI Migration Design

## Summary

Migrate the Home Manager AI module in this repo from Gemini CLI naming to Antigravity CLI naming completely at the repo level. The resulting source of truth will be `modules/home-manager/ai/antigravity-cli/` and the user-facing module options will be `modules.antigravity-cli` and `modules.ai.antigravity-cli`.

This is a hard cutover, not a compatibility migration. Gemini-branded repo module paths, option names, docs references, package selection, and shell aliases will be removed instead of kept as deprecated aliases.

## Goal

Expose a clean Antigravity CLI module in Home Manager configuration while preserving the existing Antigravity CLI behavior already configured through `programs.antigravity-cli`.

## Non-Goals

- Do not keep a deprecated `modules.gemini-cli` wrapper.
- Do not keep a `modules.ai.gemini-cli` aggregate toggle.
- Do not keep the `gemini` shell alias.
- Do not patch or fork the upstream Home Manager `programs.antigravity-cli` module.

## Current State

The repo currently has a local module at `modules/home-manager/ai/gemini-cli/default.nix`, but that module already configures `programs.antigravity-cli`. This creates an inconsistent setup where the repo-facing module is Gemini-branded while the underlying Home Manager program module is Antigravity-branded.

The current module also pins `package = pkgs.gemini-cli` and installs a `gemini` shell alias, which conflicts with the requested clean Antigravity cutover.

## Constraints

The local `home-configuration.nix` man page for the current Home Manager version shows that `programs.antigravity-cli` still writes some generated runtime files under `~/.gemini/`, including context files, MCP config, and settings. The user explicitly accepted this remaining runtime detail.

Because of that upstream behavior, "remove Gemini completely" applies to this repo's source layout, option naming, package choice, and shell UX, but not to the generated runtime path behavior implemented by Home Manager itself.

## Proposed Design

### Module Structure

- Rename `modules/home-manager/ai/gemini-cli/` to `modules/home-manager/ai/antigravity-cli/`.
- Rename the local module option namespace from `modules.gemini-cli` to `modules.antigravity-cli`.
- Update the AI aggregate module in `modules/home-manager/ai/default.nix` to import `./antigravity-cli`.
- Rename the aggregate toggle from `modules.ai.gemini-cli` to `modules.ai.antigravity-cli`.

### Program Configuration

The local module will continue to configure `programs.antigravity-cli` directly. The configuration for commands, context files, settings, MCP integration, auth, permissions, and model selection remains under that Home Manager program module.

To align with the clean migration:

- Remove `package = pkgs.gemini-cli`.
- Allow `programs.antigravity-cli` to use its default package unless another Antigravity-specific package choice is already available in this repo.
- Remove the `gemini` shell alias entirely.

### Context File Handling

The current module symlinks a repo file into `~/.gemini/GEMINI.md`. The Home Manager man page indicates that Antigravity CLI supports configurable context filenames through `settings.context.fileName` and `programs.antigravity-cli.context`.

The repo should stop treating `GEMINI.md` as the canonical source filename. The migration should:

- Rename the repo-managed context file to `AGENTS.md`.
- Update the local module so the configured context filename list prefers the new filename.
- Keep compatibility only to the extent required by the upstream Antigravity CLI module behavior.

The repo-managed source file will therefore move to `modules/home-manager/ai/antigravity-cli/AGENTS.md`. Home Manager may still place generated context files under `~/.gemini/`, which is acceptable for this migration.

### Documentation

Update repo documentation so it consistently describes Antigravity CLI:

- `docs/MODULES.md`
- `docs/AI-MCP-ARCHITECTURE.md`
- Any other repo references to `modules.gemini-cli`, `modules/home-manager/ai/gemini-cli/`, or Gemini CLI as the configured tool

Documentation should describe the remaining `~/.gemini/*` runtime path behavior as an upstream Home Manager detail rather than repo intent.

## File Changes

### Files to Rename or Move

- `modules/home-manager/ai/gemini-cli/default.nix` -> `modules/home-manager/ai/antigravity-cli/default.nix`
- `modules/home-manager/ai/gemini-cli/GEMINI.md` -> `modules/home-manager/ai/antigravity-cli/AGENTS.md`

### Files to Modify

- `modules/home-manager/ai/default.nix`
- `docs/MODULES.md`
- `docs/AI-MCP-ARCHITECTURE.md`

### Files to Remove

- Any remaining repo references that keep Gemini CLI as a configured module identity

## Data Flow After Migration

`modules.ai.antigravity-cli` will control whether the aggregate AI module enables `modules.antigravity-cli`. That local module will then render the actual `programs.antigravity-cli` Home Manager configuration. The runtime config produced by Home Manager may still live partly under `~/.gemini/`, but all repo-level ownership and user-facing configuration will be Antigravity CLI.

## Risks

### Runtime Path Mismatch

Even after the repo migration, generated files may still appear under `~/.gemini/`. This could surprise future readers unless the docs call it out clearly.

### Context Filename Compatibility

If the CLI or existing workflows implicitly rely on `GEMINI.md`, renaming the repo-side context file may require updating the configured `settings.context.fileName` list carefully.

### Downstream Config References

Other local modules or docs may still reference `modules.gemini-cli` or the old path. These need to be found and updated to avoid evaluation errors or stale documentation.

## Validation

The migration is complete when:

- No repo module path remains named `gemini-cli`.
- No repo option namespace remains `modules.gemini-cli`.
- No aggregate toggle remains `modules.ai.gemini-cli`.
- The repo no longer pins `pkgs.gemini-cli`.
- The repo no longer defines a `gemini` shell alias.
- Documentation consistently points to Antigravity CLI.
- Home Manager evaluation still succeeds for the affected modules.

## Open Decision Already Resolved

The user approved a clean Antigravity cutover and explicitly accepted that the current Home Manager Antigravity module may still generate runtime files under `~/.gemini/*`.
