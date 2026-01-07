# Agent Instructions

## Quick Reference

| Scenario             | Parallel? | Tool                            |
| -------------------- | --------- | ------------------------------- |
| **Plan Execution**   | ALWAYS    | `Task` per todo in ONE message  |
| **Shell Commands**   | ALWAYS    | `Task` per command in ONE msg   |
| **Codebase Explore** | ALWAYS    | `Task(subagent_type="Explore")` |
| **Everything Else**  | NO        | Work sequentially               |

---

## Core Principles

### 1. TodoWrite ≠ Execution

```
TodoWrite = PLANNING TOOL (create list, track status)
Task      = EXECUTION TOOL (do the actual work)

CRITICAL: After creating todos, execute them via Task agents!
```

### 2. Parallel ONLY for These Cases

```
┌─────────────────────────────────────────────────────────────┐
│  MUST PARALLELIZE (no exceptions):                          │
│  ├── Plan Execution: All independent todos → parallel Tasks │
│  ├── Shell Commands: Multiple commands → parallel Tasks     │
│  └── Exploration: Always delegate to Explore agent          │
│                                                              │
│  EVERYTHING ELSE: Work sequentially (default mode)          │
└─────────────────────────────────────────────────────────────┘
```

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

## Mandatory Parallel Cases

### 1. Plan Execution (ALWAYS PARALLEL)

When executing todos from a plan, launch ALL independent Task agents in ONE message:

```javascript
// ✅ CORRECT - Execute plan todos via parallel Task agents
TodoWrite([...todos...])  // Plan first
// Then in ONE message:
Task("Fix auth bug", prompt="Fix the auth bug in...", "general-purpose")
Task("Update tests", prompt="Update tests for...", "general-purpose")
Task("Update docs", prompt="Update documentation...", "general-purpose")
// Mark todos complete as Tasks return
```

```javascript
// ❌ WRONG - Creating todos then doing work inline sequentially
TodoWrite([...todos...])
// Then doing each task yourself one by one...
```

### 2. Shell Commands (ALWAYS PARALLEL)

Multiple independent shell commands MUST run as parallel Task agents:

```javascript
// ✅ CORRECT - Task subagents run in TRUE parallel
Task("Delete table1", "bq rm project:dataset.table1", "general-purpose");
Task("Delete table2", "bq rm project:dataset.table2", "general-purpose");
Task("Delete table3", "bq rm project:dataset.table3", "general-purpose");
// All in ONE message
```

```javascript
// ❌ WRONG - Bash is sequential even with multiple calls
bq rm table1 && bq rm table2 && bq rm table3
```

### 3. Exploration (ALWAYS DELEGATE)

Always delegate exploration to the Explore agent:

```javascript
// ✅ CORRECT - Delegate to explorer
Task(
  (subagent_type = "Explore"),
  (prompt = "Find all auth-related code and patterns"),
);
```

```javascript
// ❌ WRONG - Sequential exploration
Grep("pattern1")... then Grep("pattern2")... then Read(file)...
```

---

## Plan Mode Strategy

When planning, group work for parallel execution:

**Preferred: By Module**

```
Module: auth (auth.ts, session.ts, middleware.ts)
Module: api (routes.ts, handlers.ts)
Module: database (schema.ts, migrations.ts)
→ 3 parallel Task agents, all in ONE message
```

**Fallback: By File** when module boundaries are unclear.

---

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
- [ ] **Executing a plan?** → Launch parallel Task agents (MANDATORY)
- [ ] **Multiple shell commands?** → Launch parallel Task agents (MANDATORY)
- [ ] **Exploration needed?** → Use `Task(subagent_type="Explore")` (MANDATORY)
- [ ] **Everything else?** → Work sequentially (default)

---

## Example Workflow

```
User: "Implement user authentication"

1. PLAN - TodoWrite: Create task breakdown (batch all todos)
   - [ ] Explore existing auth code
   - [ ] Implement backend auth
   - [ ] Implement frontend auth
   - [ ] Add tests

2. EXPLORE - Delegate to explorer (MANDATORY parallel):
   Task(subagent_type="Explore", prompt="Find existing auth patterns, user models, API routes")
   // Wait for explore results, then:

3. EXECUTE PLAN - Parallel Task agents (MANDATORY parallel, ONE message):
   Task("Backend auth", prompt="Implement backend auth with JWT...", "general-purpose")
   Task("Frontend auth", prompt="Implement frontend auth forms...", "general-purpose")
   Task("Auth tests", prompt="Write tests for auth flow...", "general-purpose")

4. UPDATE - TodoWrite: Mark each todo complete AS Tasks return
   // Don't wait until the end - update status in real-time

KEY: Never do todo work yourself inline. Always delegate to Task agents.
```
