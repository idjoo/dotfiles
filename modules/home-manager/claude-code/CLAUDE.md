# Agent Instructions

> **These mandatory rules govern all interactions. Violations are unacceptable.**

## Quick Reference

| Rule           | Requirement                                                   |
| -------------- | ------------------------------------------------------------- |
| **TodoWrite**  | FIRST action for 2+ step tasks; no exceptions                 |
| **Parallel**   | Batch independent tool calls in ONE message                   |
| **Bash**       | Chain commands in ONE call using `&&` or `;`                  |
| **Context7**   | Query docs BEFORE writing library/framework code              |
| **Playwright** | Screenshot to `latest.png` AFTER screen-changing actions      |
| **Tmux**       | Use MCP tools (not Bash); `rawMode` for REPLs; no heredocs    |

---

## 1. Task Management

**ALWAYS use TodoWrite BEFORE starting any multi-step task. No exceptions.**

### Triggers (If ANY apply, use TodoWrite FIRST)

- Request involves 2+ tool calls
- Request involves 2+ sequential actions
- Bug fixes, features, refactors, investigations
- Tmux operations (session + command = multi-step)
- Playwright automation (navigate + interact = multi-step)

### Rules

1. **FIRST action**: Call TodoWrite to create the task list
2. One `in_progress` at a time
3. Mark `completed` **immediately** after finishing each task
4. Break large tasks into atomic items

### Pattern

```
"Create tmux session and run command" →
  ☐ Check existing sessions
  ☐ Create new session
  ☐ Execute command
  ☐ Verify result

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

### Bash Exception

Chain shell commands in ONE Bash call:

```
✓ Bash("npm test && npm run lint && npm run build")
✗ Bash("npm test") + Bash("npm run lint")  ← Never parallel
```

**Operators:** `&&` stops on failure; `;` continues regardless

### Sequential Only When

Tool B requires Tool A's **output** (true data dependency)

---

## 3. Context7 Documentation

**Query docs BEFORE writing library code. Never trust training data alone.**

### Workflow

```
1. resolve-library-id(name, query)  → Get library ID
2. query-docs(libraryId, question)  → Get current docs
3. Implement based on results
```

### Required For

- External libraries (React, FastAPI, Prisma, Next.js, etc.)
- Frequently-updated packages
- Uncertain API syntax
- Any non-trivial import

### Pattern

```
User: "Add NextAuth"

✓ resolve-library-id("nextauth") → query-docs(...) → implement
✗ Write code from memory  ← May be outdated
```

---

## 4. Playwright MCP

**Take screenshots after every screen-changing action.**

### Rule

After any screen-modifying tool, call `browser_take_screenshot`:

```
filename: "/tmp/playwright/screenshot/latest.png"
```

### Screen-Changing Tools

`browser_navigate`, `browser_click`, `browser_type`, `browser_fill_form`,
`browser_select_option`, `browser_press_key`, `browser_handle_dialog`,
`browser_file_upload`, `browser_tabs` (select/new)

### Pattern

```
browser_click(element, ref) → browser_take_screenshot(filename: "...")
```

---

## 5. Tmux MCP

**ALWAYS use Tmux MCP tools instead of Bash for tmux operations.**

### Tool Preference

```
✓ mcp__tmux__create-session, execute-command, capture-pane
✗ Bash("tmux new-session ..."), Bash("tmux send-keys ...")
```

### Session Management

1. **Check first**: `list-sessions` → `find-session` before creating
2. **Reuse**: Connect to existing sessions when possible
3. **Name descriptively**: Use meaningful session/window names
4. **Clean up**: `kill-session` when work is complete

### Command Execution

| Scenario              | Mode                  | Follow-up           |
| --------------------- | --------------------- | ------------------- |
| Standard commands     | `rawMode: false`      | `get-command-result`|
| REPLs (python, node)  | `rawMode: true`       | `capture-pane`      |
| TUI apps (vim, btop)  | `noEnter: true`       | `capture-pane`      |
| Interactive prompts   | `rawMode: true`       | `capture-pane`      |

### Critical Restrictions

**NEVER use heredocs** when `rawMode: false`:

```
✗ execute-command: cat << EOF > file.txt
✓ Use Write tool instead
✓ execute-command: printf 'line1\nline2' > file.txt
✓ execute-command: echo "content" > file.txt
```

### Pattern

```
# Standard command
execute-command(paneId, "ls -la") → get-command-result(commandId)

# REPL interaction
execute-command(paneId, "python3", rawMode: true)
execute-command(paneId, "print('hello')", rawMode: true) → capture-pane(paneId)

# TUI navigation
execute-command(paneId, "j", noEnter: true) → capture-pane(paneId)
```

---

## Violations

| Category       | Violation                                          |
| -------------- | -------------------------------------------------- |
| **Todos**      | Starting multi-step work without a todo list       |
| **Todos**      | Batching completions instead of immediate updates  |
| **Tools**      | Sequential calls when parallel is possible         |
| **Bash**       | Multiple Bash calls instead of chaining            |
| **Docs**       | Writing library code without Context7 lookup       |
| **Docs**       | Assuming training data has current APIs            |
| **Playwright** | Skipping screenshot after screen-changing action   |
| **Tmux**       | Using `Bash("tmux ...")` instead of Tmux MCP tools |
| **Tmux**       | Using heredocs with `rawMode: false`               |
| **Tmux**       | Creating new sessions without checking existing    |
