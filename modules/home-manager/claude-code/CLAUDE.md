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

## Python Guidelines

When working with Python projects:

1. **Toolchain:** Always use `uv` and `ruff` exclusively.

2. **Package Management (uv):**
   - `uv sync` - Install dependencies from lockfile
   - `uv add <package>` - Add a dependency
   - `uv remove <package>` - Remove a dependency
   - `uv run <command>` - Run command in project environment

3. **Linting/Formatting (ruff):**
   - `ruff check .` - Lint code
   - `ruff check --fix .` - Lint and auto-fix
   - `ruff format .` - Format code

4. **Code Style:**
   - Use type hints for all public functions
   - Use `pyproject.toml` for all configuration
   - Use 4-space indentation
   - Follow PEP 8 naming conventions

5. **Testing:**
   - Run `uv run pytest` to verify changes
   - Use fixtures for test setup

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

## Workflow Best Practices

These practices are inspired by Boris Cherny (creator of Claude Code).

### Start with Planning

Most sessions should start in **Plan mode** (shift+tab twice in the terminal). When writing a Pull Request:
1. Use Plan mode and go back and forth until the plan looks good
2. Switch to auto-accept edits mode
3. Claude can usually one-shot the implementation from a good plan

### Use Slash Commands

Use slash commands for repetitive workflows:
- `/commit` - Smart atomic commits with Conventional Commits
- `/pr` - Commit, push, and create PR in one workflow

### Use Subagents for Post-Processing

After Claude finishes implementing:
- `code-simplifier` - Simplifies and cleans up code
- `verify-build` - Runs linters, tests, and builds
- `code-reviewer` - Reviews code for quality and security

### Verification is Key

Always give Claude a way to verify its work:
- Run test suites after changes
- Use linters and type checkers
- For UI changes, test in browser/simulator
- A feedback loop 2-3x the quality of final results

### Long-Running Tasks

For tasks that take a while:
1. Use background agents to verify work when done
2. Consider using Agent Stop hooks for deterministic verification
3. Use `--permission-mode=dontAsk` in sandboxed environments
