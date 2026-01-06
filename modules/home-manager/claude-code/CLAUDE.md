# Global Agent Context

This file contains persistent memories and instructions for Claude Code.

## Core Tool Preference

**Mandate:** Always prefer the Claude Code core tools (e.g., `Bash`, `Read`, `Write`, `Edit`, `Glob`, `Grep`) over external or complex specialized tools whenever possible, unless a specialized tool is explicitly required for the task.

## Package Management

To determine which JavaScript package manager a project uses, look for the specific lock file located in the project's root directory:

| Lock File                | Package Manager |
| :----------------------- | :-------------- |
| `package-lock.json`      | `npm`           |
| `pnpm-lock.yaml`         | `pnpm`          |
| `yarn.lock`              | `yarn`          |
| `bun.lockb` / `bun.lock` | `bun`           |

## Tool Usage Guidelines

### Task Management (TodoWrite Tool)

**Mandate:** The `TodoWrite` tool is the primary mechanism for state and task tracking. You MUST use it for every interaction that involves more than a single immediate action.

**Workflow:**
1. **Plan:** Immediately break down the user's request into actionable steps and add them using the `TodoWrite` tool.
2. **Execute & Update:** As you complete each step, mark it as done using the `TodoWrite` tool before moving to the next.
3. **Persist:** Ensure the todo list reflects the current state of the task at all times.

### MCP Tools

When MCP tools are available, use them appropriately:

1. **Context7 / Documentation Tools:** Use for looking up library documentation before writing code involving 3rd party libraries.
2. **In Memoria:** Use for intelligent codebase navigation and analysis when available.

## Nix/NixOS Guidelines

When working with Nix configurations:

1. **Prefer Declarative:** Always prefer declarative Nix configurations over imperative commands.
2. **Use Flakes:** This repository uses Nix flakes - respect the `flake.nix` and `flake.lock`.
3. **Home Manager:** User-level configurations should go through home-manager modules.
4. **Darwin:** macOS system configurations use nix-darwin.

## Git Workflow

1. **Conventional Commits:** Use conventional commit format (feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert).
2. **Atomic Commits:** Keep commits atomic and focused on a single change.
3. **Descriptive Messages:** Write clear, descriptive commit messages focusing on "why" over "what".
