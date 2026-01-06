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

#### In Memoria Quick Start

Every new session, follow this pattern:

1. Call `get_project_blueprint()` to get instant context
2. Check `learningStatus` in the blueprint response
3. If `recommendation !== 'ready'`, call `auto_learn_if_needed()`
4. Use the blueprint to understand tech stack, entry points, and key directories
5. Leverage feature maps and semantic search for navigation

#### Core In Memoria Tools

| Tool | When to Use |
|------|-------------|
| `get_project_blueprint` | **Every session start** - Instant context: tech stack, entry points, architecture |
| `auto_learn_if_needed` | When learning recommended - Smart learning with staleness detection |
| `predict_coding_approach` | Before implementing - Get approach + file routing + patterns |
| `search_codebase` | Finding code - Semantic (meaning), text (keywords), or pattern search |
| `analyze_codebase` | Understanding files/dirs - Token-efficient analysis |
| `get_pattern_recommendations` | Pattern suggestions with related files |
| `get_developer_profile` | Coding style and conventions |

#### Decision Tree: Which Tool to Use?

```
Need instant project context?
  → get_project_blueprint()

Need to learn/update intelligence?
  → auto_learn_if_needed() (smart) OR learn_codebase_intelligence() (force)

Need implementation guidance?
  → predict_coding_approach() with includeFileRouting=true

Need to find code?
  ├─ By meaning/concept? → search_codebase(type='semantic')
  ├─ By keyword? → search_codebase(type='text')
  └─ By pattern? → search_codebase(type='pattern')

Need to understand a file?
  → analyze_codebase(path='./specific/file.ts')

Need coding patterns?
  → get_pattern_recommendations() with includeRelatedFiles=true

Need coding style/conventions?
  → get_developer_profile()
```

#### Recommended Session Flow

```typescript
// === SESSION START ===

// 1. Get instant context + learning status
const blueprint = await mcp.get_project_blueprint({
  path: '.',
  includeFeatureMap: true
});

// 2. Learn if needed (automatic staleness check)
if (blueprint.learningStatus.recommendation !== 'ready') {
  await mcp.auto_learn_if_needed({ path: '.' });
}

// 3. Understand coding style (once per session)
const profile = await mcp.get_developer_profile({});

// === DURING WORK ===

// 4. For each task, get approach + routing
const approach = await mcp.predict_coding_approach({
  problemDescription: userRequest,
  includeFileRouting: true
});

// 5. Get patterns for consistency
const patterns = await mcp.get_pattern_recommendations({
  problemDescription: userRequest,
  currentFile: approach.fileRouting?.suggestedStartPoint,
  includeRelatedFiles: true
});

// 6. Search for relevant code as needed
const examples = await mcp.search_codebase({
  query: relevantConcept,
  type: 'semantic',
  limit: 5
});
```

#### Common Mistakes to Avoid

| ❌ DON'T | ✅ DO |
|----------|-------|
| Skip the learning check | Always check blueprint.learningStatus first |
| Use text search for concepts | Use semantic search for conceptual queries |
| Ignore pattern recommendations | Check patterns before implementing |
| Force re-learning unnecessarily | Trust the staleness detection |

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
