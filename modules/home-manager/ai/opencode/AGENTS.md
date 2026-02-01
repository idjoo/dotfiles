# Agent Instructions

These mandatory rules govern all interactions. Violations are unacceptable.

## Quick Reference

| Rule | Requirement |
|------|-------------|
| **todowrite** | FIRST action for 2+ step tasks |
| **question** | Use for ALL user interactions (choices, clarifications, interviews) |
| **Parallel** | Batch independent tool calls in ONE message |
| **bash** | Chain commands in ONE call (`&&` or `;`) |
| **Python** | ALWAYS `uv run` - NEVER bare `python`/`python3` |
| **lsp** | Prefer over grep for code navigation |
| **Delegate** | Use subagents for specialized tasks |
| **Verify** | Test changes before marking complete |
| **skill** | Load skills when task matches (context7, playwright, tmux) |

---

## User Interaction: question Tool

**Principle**: ALWAYS use the `question` tool when interacting with the user.

**When to use** (if ANY apply, use `question`):
- Presenting options or choices
- Clarifying ambiguous instructions
- Gathering requirements or preferences
- Interviewing the user for information
- Getting decisions on implementation approaches
- Confirming before destructive actions

**Structure**:
```json
{
  "questions": [{
    "header": "Short label (max 30 chars)",
    "question": "Complete question text",
    "options": [
      {"label": "Option 1", "description": "What this does"},
      {"label": "Option 2", "description": "What this does"}
    ],
    "multiple": false
  }]
}
```

**Rules**:
- Put recommended option FIRST with "(Recommended)" suffix
- Don't add "Other" option - custom answers are automatic
- Use `multiple: true` when user can select more than one
- Keep labels concise (1-5 words)
- Batch related questions in one call

```
✓ question(header: "Auth Method", options: ["JWT (Recommended)", "Session", "OAuth"])
✗ Asking "Which do you prefer: JWT, Session, or OAuth?" in plain text
```

---

## Task Management

**Principle**: ALWAYS use `todowrite` BEFORE starting any multi-step task.

**Triggers** (if ANY apply, `todowrite` FIRST):
- Request involves 2+ tool calls or sequential actions
- Bug fixes, features, refactors, investigations
- Browser automation (navigate + interact = multi-step)

**Rules**:
- One `in_progress` at a time
- Mark `completed` immediately after each task
- Break large tasks into atomic items

**Example**:
```
"Fix login bug" → todowrite:
  1. Investigate error logs
  2. Identify root cause
  3. Implement fix
  4. Verify solution
```

---

## Tool Execution Strategy

### Parallel Calls (Default)

Batch independent operations in ONE message.

```
✓ read(auth.ts) + read(config.ts) + grep("TODO") → Single message
✗ Message 1: read(auth.ts) → Message 2: read(config.ts) → Wastes turns
```

### bash Commands

Chain shell commands in ONE `bash` call.

```
✓ bash("npm test && npm run lint && npm run build")
✗ bash("npm test") + bash("npm run lint") → Never parallel
```

Operators: `&&` stops on failure; `;` continues regardless.

### Python Execution

**ALWAYS use `uv run`. NEVER bare `python` or `python3`.**

Why: Instant dependency resolution, isolated environments, reproducible execution.

| Pattern | Correct | Incorrect |
|---------|---------|-----------|
| With deps | `uv run --with requests script.py` | `python script.py` |
| Inline | `uv run python -c 'print(1)'` | `python -c 'print(1)'` |
| Module | `uv run python -m pytest` | `python -m pytest` |
| Multi-dep | `uv run --with pandas --with numpy script.py` | — |

### Sequential Only When

Tool B requires Tool A's output (true data dependency).

---

## lsp Tool

**Principle**: Use `lsp` for code navigation instead of `grep`/search when possible.

| Operation | lsp operation | Use For |
|-----------|---------------|---------|
| Find definition | `goToDefinition` | Jump to symbol definition |
| Find references | `findReferences` | All usages across workspace |
| Get type info | `hover` | Type signature, documentation |
| File symbols | `documentSymbol` | Outline of file structure |
| Workspace search | `workspaceSymbol` | Find symbol by name globally |
| Go to impl | `goToImplementation` | Find interface implementations |
| Call hierarchy | `prepareCallHierarchy` | Get call hierarchy at position |
| Incoming calls | `incomingCalls` | Functions that call this function |
| Outgoing calls | `outgoingCalls` | Functions called by this function |

```
✓ lsp goToDefinition("auth.ts", 42, 15) → Precise definition
✗ grep("function authenticate") → May match comments, strings, wrong functions
```

LSP servers auto-start for: TypeScript, Python, Go, Rust, C/C++, Java, and more.

---

## Verification

**Principle**: Verify changes work before marking tasks complete.

| Change Type | Verification |
|-------------|--------------|
| Code changes | Run relevant tests or type-check |
| Config changes | Validate syntax/format |
| Bug fixes | Reproduce fix, confirm resolution |
| New features | Demonstrate functionality works |

```
After implementing fix:
  1. Run targeted test: npm test path/to/file.test.ts
  2. Verify no regressions
  3. THEN mark todo as completed

✓ Fix → Test → Verify → Complete
✗ Fix → Complete → Hope it works
```

---

## Skills

**Principle**: Load skills for specialized workflows using the `skill` tool.

| Skill | When to Use |
|-------|-------------|
| context7 | Writing code with external libraries |
| playwright | Browser automation tasks |
| tmux | Terminal multiplexing, background processes |

**Context7 Workflow**:
```
User: "Add NextAuth to the project"

1. skill("context7")
2. context7_resolve-library-id("nextauth", "setup authentication")
3. context7_query-docs(libraryId, "NextAuth configuration")
4. Implement based on current docs

✓ Query docs → Implement based on results
✗ Write library code from training data → May be outdated
```

---

## Error Recovery

**Principle**: Handle failures gracefully without user intervention when possible.

| Error | Recovery |
|-------|----------|
| Command fails | Read error message, fix issue, retry |
| Test fails | Analyze failure, fix code, re-run |
| File not found | Search for correct path with `glob` |
| LSP unavailable | Fall back to `grep`/AST-grep |
| MCP timeout | Retry with simpler request |

After 2 failed attempts at the same approach, try a different strategy or ask user for guidance.

---

## Violations

| Category | Violation |
|----------|-----------|
| Todos | Starting multi-step work without a todo list |
| Todos | Batching completions instead of immediate updates |
| question | Asking choices/options in plain text instead of using `question` tool |
| Tools | Sequential calls when parallel is possible |
| bash | Multiple `bash` calls instead of chaining |
| Python | Using bare `python` or `python3` instead of `uv run` |
| lsp | Using `grep`/search when `lsp` would give precise results |
| Verify | Marking complete without testing changes |
| Skills | Ignoring available skills for specialized tasks |
| Context7 | Writing library code without querying docs first |
