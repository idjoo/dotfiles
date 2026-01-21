# Agent Instructions

> **These mandatory rules govern all interactions. Violations are unacceptable.**

## Quick Reference

| Rule          | Requirement                                                  |
| ------------- | ------------------------------------------------------------ |
| **TodoWrite** | FIRST action for 2+ step tasks; no exceptions                |
| **Parallel**  | Batch independent tool calls in ONE message                  |
| **Bash**      | Chain commands in ONE call                                   |

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

## Violations

| Category  | Violation                                         |
| --------- | ------------------------------------------------- |
| **Todos** | Starting multi-step work without a todo list      |
| **Todos** | Batching completions instead of immediate updates |
| **Tools** | Sequential calls when parallel is possible        |
| **Bash**  | Multiple Bash calls instead of chaining           |
| **Serena**| Using Serena tools without reading initial instructions |
