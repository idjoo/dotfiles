# Agent Instructions

## 🚨 STOP - READ THIS FIRST

**Before ANY multi-item task, you MUST:**
1. **FIRST** → Use `TodoWrite` to plan ALL tasks
2. **THEN** → Execute each todo with `Task(..., run_in_background=true)`
3. **NEVER** → Use sequential Write/Edit/Bash for 2+ independent items

---

## Core Philosophy: TRUE PARALLELISM

```
┌─────────────────────────────────────────────────────────────┐
│  WORKFLOW: TodoWrite FIRST → Parallel Task Agents           │
│                                                              │
│  1. TodoWrite([{content: "task1"}, {content: "task2"}])     │
│  2. Task("task1", run_in_background=true, ...)              │
│  3. Task("task2", run_in_background=true, ...)              │
│  4. TaskOutput(task_id=...) for each                        │
│                                                              │
│  ⚠️  2+ items = MUST use this workflow                      │
└─────────────────────────────────────────────────────────────┘
```

---

## ⚠️ MANDATORY PARALLEL TRIGGERS

**You MUST use `Task(..., run_in_background=true)` when ANY of these apply:**

| Condition | Example | Action |
|-----------|---------|--------|
| Creating 2+ files | "Create auth.py and user.py" | Spawn 2 background Task agents |
| Implementing 2+ features | "Add login and signup" | Spawn 2 background Task agents |
| Running 2+ independent commands | "Run tests and lint" | Spawn 2 background Task agents |
| Multiple independent searches | "Find auth and API code" | Spawn 2 background Explore agents |

### ❌ NEVER DO THIS:
```javascript
// WRONG - Sequential Write/Edit calls for multiple files
Write("auth.py", ...)
Write("user.py", ...)
Write("utils.py", ...)
// These execute SEQUENTIALLY, wasting time!
```

### ✅ ALWAYS DO THIS:
```javascript
// CORRECT - Background Task agents for parallel execution
Task("Create auth.py", run_in_background=true, subagent_type="general-purpose", prompt="Create auth.py with login/logout functions")
Task("Create user.py", run_in_background=true, subagent_type="general-purpose", prompt="Create user.py with CRUD functions")
Task("Create utils.py", run_in_background=true, subagent_type="general-purpose", prompt="Create utils.py with helper functions")
// Then collect results:
TaskOutput(task_id="...")
```

---

## How Parallelism Actually Works

**FACT**: Multiple tool calls in a single message execute **sequentially**, not in parallel.

Tested empirically: Three `sleep 2` commands in one message took ~17 seconds, not ~2 seconds.

### True Parallelism: Background Task Agents

```javascript
// ✅ TRUE PARALLEL - Launch background agents
Task("Implement auth", run_in_background=true, ...)
Task("Implement user", run_in_background=true, ...)
Task("Write tests", run_in_background=true, ...)
// All three run concurrently! Continue working while they execute.
// Use TaskOutput(task_id) to retrieve results when needed.
```

---

## When to Use What

### Direct Tools (Write, Edit, Bash, Read, etc.)
Use ONLY for single operations:
```
✅ ONE file creation/edit
✅ ONE command
✅ Reading files
```

### Task Agents (Background) - MANDATORY FOR 2+ ITEMS
**MUST use for any 2+ independent operations:**
```
⚠️ 2+ file creations → background Task agents
⚠️ 2+ feature implementations → background Task agents
⚠️ 2+ independent commands → background Task agents
⚠️ Long-running operations → background Task agent
```

### Task Agents (Foreground)
Use for complex sequential work where steps depend on each other:
```
✅ Multi-step work where step N depends on step N-1
✅ Research requiring decisions between steps
```

---

## Parallelism Patterns

### Pattern 1: Parallel Feature Implementation
```javascript
// ✅ TRUE PARALLEL - Background agents run concurrently
Task("Implement auth module", run_in_background=true, prompt="...", subagent_type="general-purpose")
Task("Implement user module", run_in_background=true, prompt="...", subagent_type="general-purpose")
Task("Write integration tests", run_in_background=true, prompt="...", subagent_type="general-purpose")

// Continue with other work...
// Later, collect results:
TaskOutput(task_id="auth-task-id")
TaskOutput(task_id="user-task-id")
TaskOutput(task_id="tests-task-id")
```

### Pattern 2: Background Long-Running Operations
```javascript
// ✅ Run tests in background while continuing work
Task("Run full test suite", run_in_background=true, prompt="npm test", subagent_type="general-purpose")

// Continue editing files, making changes...
Edit("src/feature.ts", ...)

// Check test results when ready
TaskOutput(task_id="test-task-id", block=true)
```

### Pattern 3: Parallel Exploration
```javascript
// ✅ Multiple explorations in parallel
Task("Find auth patterns", run_in_background=true, subagent_type="Explore", prompt="...")
Task("Find API routes", run_in_background=true, subagent_type="Explore", prompt="...")
Task("Find test patterns", run_in_background=true, subagent_type="Explore", prompt="...")
```

---

## Anti-Patterns

```javascript
// ❌ WRONG - This is NOT parallel (executes sequentially)
Task("First feature", ...)
Task("Second feature", ...)

// ❌ WRONG - Expecting parallel from multiple Bash calls
Bash("npm test")
Bash("npm run lint")
Bash("npm run build")
// These run one after another, not concurrently!

// ❌ WRONG - Task agent for trivial work
Task("Fix typo in README", ...)  // Just use Edit directly

// ✅ CORRECT - Use run_in_background for true parallelism
Task("First feature", run_in_background=true, ...)
Task("Second feature", run_in_background=true, ...)
```

---

## ⚠️ MANDATORY WORKFLOW: TodoWrite First, Then Parallel

**For ANY task with 2+ items, you MUST follow this workflow:**

### Step 1: ALWAYS Use TodoWrite First
```javascript
// FIRST - Plan all tasks with TodoWrite
TodoWrite([
  { content: "Implement auth", status: "pending", activeForm: "Implementing auth" },
  { content: "Implement user", status: "pending", activeForm: "Implementing user" },
  { content: "Add tests", status: "pending", activeForm: "Adding tests" }
])
```

### Step 2: Execute ALL Todos in Parallel
```javascript
// THEN - Launch background agents for EACH todo item
Task("Implement auth", run_in_background=true, subagent_type="general-purpose", prompt="...")
Task("Implement user", run_in_background=true, subagent_type="general-purpose", prompt="...")
Task("Add tests", run_in_background=true, subagent_type="general-purpose", prompt="...")
```

### Step 3: Collect Results and Update Todos
```javascript
// Collect results and mark todos completed
TaskOutput(task_id="auth-id")  // then TodoWrite to mark auth completed
TaskOutput(task_id="user-id")  // then TodoWrite to mark user completed
TaskOutput(task_id="test-id")  // then TodoWrite to mark tests completed
```

### ❌ NEVER skip TodoWrite for multi-item tasks
### ❌ NEVER execute todos sequentially when they're independent

---

## ⚠️ Exploration - ALWAYS Parallel

**Exploration with 2+ search targets MUST be done in parallel:**

### ❌ WRONG - Sequential exploration
```javascript
Task(subagent_type="Explore", prompt="Find auth patterns")  // waits...
Task(subagent_type="Explore", prompt="Find API routes")     // then this...
// SLOW - each waits for the previous!
```

### ✅ CORRECT - Parallel exploration
```javascript
// Launch ALL explorations in background simultaneously
Task("Find auth patterns", run_in_background=true, subagent_type="Explore", prompt="...")
Task("Find API routes", run_in_background=true, subagent_type="Explore", prompt="...")
Task("Find test patterns", run_in_background=true, subagent_type="Explore", prompt="...")

// Collect results when needed
TaskOutput(task_id="auth-explore")
TaskOutput(task_id="api-explore")
TaskOutput(task_id="test-explore")
```

### Single exploration - foreground is fine
```javascript
// Only ONE exploration target - foreground is acceptable
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

Do you need TRUE parallelism?
├── YES → Use Task(..., run_in_background=true)
└── NO → Regular sequential execution is fine
```

---

## Summary

```
┌─────────────────────────────────────────────────────────────┐
│  GOLDEN RULES:                                              │
│                                                              │
│  1. 2+ items = MUST use TodoWrite FIRST to plan             │
│  2. Then execute EACH todo with background Task agents      │
│  3. Multiple tool calls in one message = SEQUENTIAL          │
│  4. True parallelism = Task(..., run_in_background=true)     │
│  5. Exploration with 2+ targets = MUST be parallel          │
│  6. Use TaskOutput to collect background task results       │
│  7. Direct tools ONLY for single operations                 │
└─────────────────────────────────────────────────────────────┘
```
