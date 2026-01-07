# Agent Instructions

## Core Philosophy: PARALLELISM

```
┌─────────────────────────────────────────────────────────────┐
│  PARALLEL BY DEFAULT                                         │
│                                                              │
│  The key: Multiple tool calls in ONE message                 │
│  Works with: Edit, Bash, Read, Task, Grep, Glob, etc.        │
└─────────────────────────────────────────────────────────────┘
```

---

## How Parallelism Actually Works

Claude Code executes **multiple tool calls in a single message** concurrently. This applies to:

| Tool Type      | Parallel Example                                    |
| -------------- | --------------------------------------------------- |
| **Edit**       | Edit file A + Edit file B → one message             |
| **Bash**       | Run tests + Run linter → one message                |
| **Task**       | Task agent 1 + Task agent 2 → one message           |
| **Read/Grep**  | Read file A + Grep pattern → one message            |

**The rule is simple: Independent operations go in ONE message.**

---

## When to Use What

### Direct Tools (Edit, Bash, Read, etc.)
Use for straightforward operations:
```
✅ Single file edits
✅ Running one or two commands
✅ Reading specific files
✅ Simple searches
```

### Task Agents
Use for complex multi-step work:
```
✅ Implementing a feature across multiple files
✅ Research/exploration requiring many searches
✅ Complex refactoring with tests
✅ Tasks that need their own decision-making
```

---

## Parallelism Patterns

### Pattern 1: Multiple Edits
```javascript
// ✅ CORRECT - Both edits in ONE message
Edit("src/auth.ts", ...)
Edit("src/user.ts", ...)
```

### Pattern 2: Multiple Commands
```javascript
// ✅ CORRECT - Independent commands in ONE message
Bash("npm test")
Bash("npm run lint")
Bash("npm run build")
```

### Pattern 3: Multiple Task Agents
```javascript
// ✅ CORRECT - Independent Task agents in ONE message
Task("Implement auth module", prompt="...", "general-purpose")
Task("Implement user module", prompt="...", "general-purpose")
Task("Write tests", prompt="...", "general-purpose")
```

### Pattern 4: Background Tasks
```javascript
// ✅ CORRECT - Long-running tasks in background
Task("Run full test suite", run_in_background=true, ...)
// Continue working while tests run
```

---

## Anti-Patterns

```javascript
// ❌ WRONG - Sequential when parallel is possible
Edit("file1.ts", ...)
// wait for response...
Edit("file2.ts", ...)

// ❌ WRONG - Chaining independent commands
Bash("npm test && npm run lint && npm run build")

// ❌ WRONG - Task agent for trivial work
Task("Fix typo in README", ...)  // Just use Edit directly

// ❌ WRONG - Sequential Task agents
Task("First feature", ...)
// wait...
Task("Second feature", ...)  // Should be in same message!
```

---

## TodoWrite for Planning

Use TodoWrite to track complex tasks:

```javascript
// 1. Plan with TodoWrite
TodoWrite([
  { content: "Implement auth", status: "pending", activeForm: "Implementing auth" },
  { content: "Implement user", status: "pending", activeForm: "Implementing user" },
  { content: "Add tests", status: "pending", activeForm: "Adding tests" }
])

// 2. Execute in parallel (ONE message)
Task("auth", ...) + Task("user", ...) + Task("tests", ...)

// 3. Update as each completes
TodoWrite([...with completed statuses...])
```

---

## Exploration

For codebase exploration, use the Explore agent:

```javascript
// ✅ CORRECT - Delegate exploration
Task(subagent_type="Explore", prompt="Find all authentication code and patterns")
```

---

## Shell Commands

### Modern CLI Tools (Prefer These)

| Legacy | Modern | Key Flags                     |
| ------ | ------ | ----------------------------- |
| `ls`   | `eza`  | `-la`, `--tree`, `--git`      |
| `find` | `fd`   | `-e ext`, `-t f/d`, `-H`      |
| `grep` | `rg`   | `-i`, `-t type`, `-C 3`, `-l` |

---

## Decision Guide

```
Is this a simple, single-location change?
├── YES → Use direct tool (Edit, Bash, etc.)
└── NO → Is it complex multi-step work?
    ├── YES → Use Task agent
    └── NO → Use direct tools

Can multiple operations run independently?
├── YES → Put ALL in ONE message (parallel execution)
└── NO → Execute sequentially with explicit dependencies
```

---

## Summary

```
┌─────────────────────────────────────────────────────────────┐
│  GOLDEN RULES:                                              │
│                                                              │
│  1. Independent operations → ONE message = parallel          │
│  2. Direct tools for simple work, Task for complex           │
│  3. Use TodoWrite to plan and track multi-step tasks        │
│  4. Explore agent for codebase investigation                │
│  5. Background tasks for long-running operations            │
└─────────────────────────────────────────────────────────────┘
```
