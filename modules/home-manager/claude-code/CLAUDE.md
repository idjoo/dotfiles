# Agent Instructions

## Quick Reference

| Directive       | When                 | Tool                             |
| --------------- | -------------------- | -------------------------------- |
| **Parallelize** | 3+ independent items | `Task` subagents in ONE message  |
| **Track**       | Multi-step work      | `TodoWrite` (planning only)      |
| **Execute**     | Each todo item       | `Task` per todo (parallel)       |
| **Explore**     | Codebase research    | `Task(subagent_type="Explore")`  |

---

## Core Principles

### 1. TodoWrite ≠ Execution

```
TodoWrite = PLANNING TOOL (create list, track status)
Task      = EXECUTION TOOL (do the actual work)

CRITICAL: After creating todos, execute them via Task agents!
```

### 2. Parallel by Default

```
Before ANY action: "Can this be split into parallel Tasks?"
├── YES → Parallelize (no permission needed)
├── UNCERTAIN → Parallelize (err on side of parallelism)
└── NO (explicit dependency) → Document why, proceed sequentially
```

**Sequential is a failure mode.** Use it only when Step B requires output from Step A.

### 3. The Execution Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│   TodoWrite ─► Plan & track (batch multiple todos at once)  │
│       ↓                                                     │
│   EXECUTE via Task ─► One Task agent per independent todo   │
│       ↓                                                     │
│   Single message ─► Launch ALL Task agents together         │
└─────────────────────────────────────────────────────────────┘
```

---

## Plan Mode Strategy

When planning, maximize parallelism by grouping work:

**Preferred: By Module**

```
Module: auth (auth.ts, session.ts, middleware.ts)
Module: api (routes.ts, handlers.ts)
Module: database (schema.ts, migrations.ts)
→ 3 parallel Task agents, all in ONE message
```

**Fallback: By File** when module boundaries are unclear.

---

## Parallelism Rules

### Automatic Triggers

| Pattern                     | Example                 | Action             |
| --------------------------- | ----------------------- | ------------------ |
| Multiple items of same type | "Delete tables A, B, C" | Task per item      |
| AND-connected operations    | "Run tests AND lint"    | Task per operation |
| Plural nouns with action    | "Restart the services"  | Task per service   |
| 3+ independent items        | Any list of 3+          | Always parallelize |

### Anti-Patterns

```javascript
// ❌ WRONG - Creating todos then doing work inline sequentially
TodoWrite([
  { content: "Fix auth bug", status: "in_progress" },
  { content: "Update tests", status: "pending" },
  { content: "Update docs", status: "pending" }
])
// Then doing each task yourself one by one...

// ✅ CORRECT - Execute todos via parallel Task agents
TodoWrite([...todos...])  // Plan first
// Then in ONE message:
Task("Fix auth bug", prompt="Fix the auth bug in...", "general-purpose")
Task("Update tests", prompt="Update tests for...", "general-purpose")
Task("Update docs", prompt="Update documentation...", "general-purpose")
// Mark todos complete as Tasks return
```

```javascript
// ❌ WRONG - Bash is sequential even with multiple calls
bq rm table1 && bq rm table2 && bq rm table3

// ✅ CORRECT - Task subagents run in TRUE parallel
Task("Delete table1", "bq rm project:dataset.table1", "general-purpose")
Task("Delete table2", "bq rm project:dataset.table2", "general-purpose")
Task("Delete table3", "bq rm project:dataset.table3", "general-purpose")
// All in ONE message
```

```javascript
// ❌ WRONG - Sequential exploration
Grep("pattern1")... then Grep("pattern2")... then Read(file)...

// ✅ CORRECT - Delegate to explorer
Task(subagent_type="Explore", prompt="Find all auth-related code and patterns")
```

## Shell Commands

### Modern CLI Tools (Prefer These)

| Legacy | Modern | Key Flags                     |
| ------ | ------ | ----------------------------- |
| `ls`   | `eza`  | `-la`, `--tree`, `--git`      |
| `find` | `fd`   | `-e ext`, `-t f/d`, `-H`      |
| `grep` | `rg`   | `-i`, `-t type`, `-C 3`, `-l` |

**Always check:** `command --help` before using unfamiliar flags.

---

## Execution Checklist

Before every action:

- [ ] TodoWrite tracking this? If not, add it NOW
- [ ] **Am I about to do work inline?** STOP. Launch a Task agent instead
- [ ] Have 2+ independent todos? Launch Task agents in ONE message
- [ ] Exploration needed? Use `Task(subagent_type="Explore")`
- [ ] Doing something sequentially that could be parallel? STOP. Fix it.

---

## Example Workflow

```
User: "Implement user authentication"

1. PLAN - TodoWrite: Create task breakdown (batch all todos)
   - [ ] Explore existing auth code
   - [ ] Implement backend auth
   - [ ] Implement frontend auth
   - [ ] Add tests

2. EXECUTE - Launch parallel Task agents for EACH todo (ONE message):
   Task(subagent_type="Explore", prompt="Find existing auth patterns, user models, API routes")
   // Wait for explore results, then:

3. EXECUTE - Parallel implementation Tasks (ONE message):
   Task("Backend auth", prompt="Implement backend auth with JWT...", "general-purpose")
   Task("Frontend auth", prompt="Implement frontend auth forms...", "general-purpose")
   Task("Auth tests", prompt="Write tests for auth flow...", "general-purpose")

4. UPDATE - TodoWrite: Mark each todo complete AS Tasks return
   // Don't wait until the end - update status in real-time

KEY: Never do todo work yourself inline. Always delegate to Task agents.
```
