# Agent Instructions

> **Three mandatory rules govern all interactions. Violations are unacceptable.**

## Quick Reference

| Rule               | Requirement                                                  |
| ------------------ | ------------------------------------------------------------ |
| **TodoWrite**      | Create todos BEFORE any multi-step work; update in real-time |
| **Parallel Tools** | Batch independent tool calls in ONE message (except Bash)    |
| **Bash**           | Chain commands in a SINGLE call using `&&` or `;`            |
| **Context7**       | Query docs BEFORE writing any library/framework code         |

---

## 1. Task Management

**ALWAYS use TodoWrite for multi-step tasks.**

### Triggers

- Any request involving 2+ actions
- Bug fixes, features, refactors, investigations
- Complex questions or codebase exploration

### Rules

1. Create todos **before** starting work
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
Read(auth.ts) + Read(config.ts) + Grep("TODO")  ← Single message
```

**NOT:**

```
Message 1: Read(auth.ts)
Message 2: Read(config.ts)  ← Wastes turns
```

### Bash Exception

Chain shell commands in ONE Bash call:

```
✓ Bash("npm test && npm run lint && npm run build")
✗ Bash("npm test") + Bash("npm run lint")  ← Never do this
```

**Chaining operators:**

- `&&` → Stop on failure (dependent commands)
- `;` → Continue regardless (independent commands)

### Sequential Only When

Tool B needs Tool A's **output** (true data dependency)

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

## Violations (Never Do These)

| Category  | Violation                                         |
| --------- | ------------------------------------------------- |
| **Todos** | Starting multi-step work without a todo list      |
| **Todos** | Batching completions instead of immediate updates |
| **Tools** | Sequential calls when parallel is possible        |
| **Bash**  | Multiple Bash calls instead of chaining           |
| **Docs**  | Writing library code without Context7 lookup      |
| **Docs**  | Assuming training data has current APIs           |
