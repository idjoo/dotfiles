# Agent Instructions

> **These mandatory rules govern all interactions. Violations are unacceptable.**

## Quick Reference

| Rule          | Requirement                                              |
| ------------- | -------------------------------------------------------- |
| **TodoWrite** | FIRST action for 2+ step tasks; no exceptions            |
| **Parallel**  | Batch independent tool calls in ONE message              |
| **Bash**      | Chain commands in ONE call                               |
| **Skills**    | Check for available skills before implementing workflows |
| **Python**    | Always use `uv run --with <deps>` for scripts            |
| **Context7**  | Use context7 skill for library/framework documentation   |

---

## 1. Task Management

**ALWAYS use TodoWrite BEFORE starting any multi-step task. No exceptions.**

### Triggers (If ANY apply, use TodoWrite FIRST)

- Request involves 2+ tool calls
- Request involves 2+ sequential actions
- Bug fixes, features, refactors, investigations
- Playwright automation (navigate + interact = multi-step)

### Rules

1. **FIRST action**: Call TodoWrite to create the task list
2. One `in_progress` at a time
3. Mark `completed` **immediately** after finishing each task
4. Break large tasks into atomic items

### Pattern

```
"Fix login bug" →
  ☐ Investigate error logs
  ☐ Identify root cause
  ☐ Implement fix
  ☐ Verify solution
```

---

## 2. Tool Execution Strategy

### Parallel Calls (Default)

Batch independent operations in ONE message:

```
✓ Read(auth.ts) + Read(config.ts) + Grep("TODO")  ← Single message
✗ Message 1: Read(auth.ts) → Message 2: Read(config.ts)  ← Wastes turns
```

### Bash Commands

Chain shell commands in ONE Bash call:

```
✓ Bash("npm test && npm run lint && npm run build")
✗ Bash("npm test") + Bash("npm run lint")  ← Never parallel
```

**Operators:** `&&` stops on failure; `;` continues regardless

### Sequential Only When

Tool B requires Tool A's **output** (true data dependency)

---

## 3. MCP Server: Serena

**Read Serena's initial instructions at session start if not already done.**

### Rule

Before using any Serena tools, call `mcp__serena__initial_instructions` to load project context and coding guidelines. This ensures proper understanding of the codebase structure and Serena's capabilities.

```
✓ Session start → mcp__serena__initial_instructions → proceed with Serena tools
✗ Using Serena tools without reading initial instructions first
```

---

## 4. Skills Usage

**Check for available skills before starting tasks. Skills provide optimized workflows.**

### Rule

Before beginning a task, check if a relevant skill exists that can handle it more effectively. Skills are specialized workflows for common operations like commits, code review, and document generation.

```
✓ User asks to commit → Check skills → Use /commit skill
✓ Creating a PDF → Check skills → Use /pdf skill
✗ Manually implementing a workflow that a skill already handles
```

### Available Skills (Examples)

- `/commit` - Smart atomic commits with Conventional Commits
- `/pdf` - PDF manipulation and creation
- `/xlsx` - Spreadsheet operations
- `/docx` - Document creation and editing
- `/pptx` - Presentation tasks

### Why

- **Consistency**: Skills follow established patterns and best practices
- **Efficiency**: Pre-built workflows avoid reinventing solutions
- **Quality**: Skills are optimized for their specific use cases

---

## 5. Python Execution

**ALWAYS use `uv run` with inline dependencies. Never use bare `python` commands.**

### Rule

When running Python scripts or one-liners, use `uv run --with <deps>` to ensure dependencies are available in an isolated environment:

```
✓ uv run --with requests python script.py
✓ uv run --with pandas,numpy python -c "import pandas as pd; ..."
✗ python script.py                    ← No dependency management
✗ pip install requests && python ...  ← Pollutes environment
```

### Why

- **Reproducibility**: Dependencies are explicit and isolated per invocation
- **No global pollution**: Avoids modifying system/user Python packages
- **Declarative**: The command shows exactly what's needed to run

---

## 6. Documentation Lookup

**Route to context7 skill. Never use web search for library docs.**

→ See `skills/context7/SKILL.md` for full workflow.

---

## Violations

| Category     | Violation                                                |
| ------------ | -------------------------------------------------------- |
| **Todos**    | Starting multi-step work without a todo list             |
| **Todos**    | Batching completions instead of immediate updates        |
| **Tools**    | Sequential calls when parallel is possible               |
| **Bash**     | Multiple Bash calls instead of chaining                  |
| **Skills**   | Manually implementing workflows when a skill exists      |
| **Python**   | Using bare `python` or `pip install` instead of `uv run` |
| **Serena**   | Using Serena tools without reading initial instructions  |
| **Context7** | Using WebSearch for library documentation instead of skill |
