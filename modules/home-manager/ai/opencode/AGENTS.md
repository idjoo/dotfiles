# Agent Instructions

> **These mandatory rules govern all interactions. Violations are unacceptable.**

## Quick Reference

| Rule          | Requirement                                    |
| ------------- | ---------------------------------------------- |
| **todowrite** | FIRST action for 2+ step tasks; no exceptions  |
| **Parallel**  | Batch independent tool calls in ONE message    |
| **Bash**      | Chain commands in ONE call (`&&` or `;`)       |
| **LSP**       | Prefer LSP over grep for code navigation       |
| **Delegate**  | Use subagents for specialized tasks            |
| **Verify**    | Test changes before marking complete           |
| **Skills**    | Load skills (Context7, Playwright) when needed |

---

## 1. Task Management

**ALWAYS use todowrite BEFORE starting any multi-step task. No exceptions.**

### Triggers (If ANY apply, use todowrite FIRST)

- Request involves 2+ tool calls
- Request involves 2+ sequential actions
- Bug fixes, features, refactors, investigations
- Playwright automation (navigate + interact = multi-step)

### Rules

1. **FIRST action**: Call todowrite to create the task list
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

## 3. LSP Tools

**Use LSP tools for code navigation instead of grep/search when possible.**

### Tool Reference

| Operation | Tool | Use Case |
|-----------|------|----------|
| Find definition | `lsp_goto_definition` | Jump to where symbol is defined |
| Find references | `lsp_find_references` | All usages across workspace |
| Get type info | `lsp_hover` | Type signature, documentation |
| File symbols | `lsp_document_symbols` | Outline of file structure |
| Workspace search | `lsp_workspace_symbols` | Find symbol by name globally |
| Rename | `lsp_rename` | Rename across entire codebase |
| Diagnostics | `lsp_diagnostics` | Errors/warnings before build |

### Rule

LSP provides semantic understanding of code. Prefer LSP operations over text-based search when you need to understand code structure, find usages, or navigate to definitions.

```
✓ lsp_goto_definition("auth.ts", 42, 15) → precise definition location
✗ Grep("function authenticate") → may find comments, strings, wrong matches

✓ lsp_find_references("config.ts", 10, 8) → all actual usages
✗ Grep("configValue") → misses renamed imports, includes false positives
```

### Requirements

LSP servers must be configured for the file type. Built-in servers auto-start for: TypeScript, Python, Go, Rust, C/C++, Java, and many more.

---

## 4. Agent Delegation

**Delegate specialized tasks to appropriate subagents.**

### When to Delegate

| Task Type | Agent | Use Case |
|-----------|-------|----------|
| Codebase exploration | `explore` | Find files, patterns, implementations |
| External docs/repos | `librarian` | Library docs, GitHub examples, remote repos |
| Complex research | `general` | Multi-step investigation, parallel work |
| Architecture decisions | `oracle` | Design guidance, deep code analysis |

### Rules

1. **Parallel agents**: Launch multiple explore/librarian agents in ONE message for broad searches
2. **Be specific**: Provide focused prompts with clear success criteria
3. **Background when possible**: Use `run_in_background: true` for non-blocking work

### Pattern

```
User: "How is authentication implemented?"

✓ Launch explore agent: "Find auth implementation patterns in this codebase"
✗ Manually grep through files one by one
```

---

## 5. Search Strategy

**Match search approach to the task.**

### Tool Selection

| Need | Tool | When |
|------|------|------|
| Semantic code understanding | LSP | Definitions, references, symbols |
| Pattern matching | Grep / AST-grep | Text patterns, code structures |
| File discovery | Glob | Find files by name/extension |
| Broad exploration | `explore` agent | Unknown scope, multiple areas |
| External resources | `librarian` agent | Docs, remote repos, examples |

### Parallel Search Pattern

For broad investigations, launch multiple searches in ONE message:

```
✓ Grep("auth") + Glob("**/auth*") + explore("Find auth patterns")  ← Parallel
✗ Grep → wait → Glob → wait → explore  ← Sequential waste
```

---

## 6. Verification

**Verify changes work before marking tasks complete.**

### Required Verification

| Change Type | Verification |
|-------------|--------------|
| Code changes | Run relevant tests or type-check |
| Config changes | Validate syntax/format |
| Bug fixes | Reproduce fix, confirm resolution |
| New features | Demonstrate functionality works |

### Pattern

```
After implementing fix:
  1. Run targeted test: npm test path/to/file.test.ts
  2. Verify no regressions
  3. THEN mark todo as completed

✓ Fix → Test → Verify → Complete
✗ Fix → Complete → Hope it works
```

---

## 7. Skills

**Load skills for specialized workflows using the `skill` tool.**

### Available Skills

| Skill | Use When |
|-------|----------|
| `context7` | Writing code with external libraries |
| `playwright` | Browser automation tasks |
| `tmux` | Terminal multiplexing, background processes |

### Context7 Workflow

```
User: "Add NextAuth to the project"

1. skill("context7")  ← Load documentation skill
2. context7_resolve-library-id("nextauth", "setup authentication")
3. context7_query-docs(libraryId, "NextAuth configuration")
4. Implement based on current docs

✓ Query docs → Implement based on results
✗ Write library code from training data  ← May be outdated
```

---

## 8. MCP Server: Serena

**Read Serena's initial instructions at session start if not already done.**

Before using any Serena tools, call `serena_initial_instructions` to load project context. This ensures proper understanding of the codebase structure.

```
✓ Session start → serena_initial_instructions → proceed with Serena tools
✗ Using Serena tools without reading initial instructions first
```

---

## 9. Error Recovery

**Handle failures gracefully without user intervention when possible.**

### Recovery Patterns

| Error Type | Recovery |
|------------|----------|
| Command fails | Read error message, fix issue, retry |
| Test fails | Analyze failure, fix code, re-run |
| File not found | Search for correct path with Glob |
| LSP unavailable | Fall back to Grep/AST-grep |
| MCP timeout | Retry with simpler request |

### Rule

After 2 failed attempts at the same approach, try a different strategy or ask user for guidance.

---

## Violations

| Category     | Violation                                               |
| ------------ | ------------------------------------------------------- |
| **Todos**    | Starting multi-step work without a todo list            |
| **Todos**    | Batching completions instead of immediate updates       |
| **Tools**    | Sequential calls when parallel is possible              |
| **Bash**     | Multiple Bash calls instead of chaining                 |
| **LSP**      | Using grep/search when LSP would give precise results   |
| **Delegate** | Manual exploration when subagent would be faster        |
| **Verify**   | Marking complete without testing changes                |
| **Skills**   | Ignoring available skills for specialized tasks         |
| **Serena**   | Using Serena tools without reading initial instructions |
| **Context7** | Writing library code without querying docs first        |
