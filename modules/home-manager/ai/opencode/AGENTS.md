# Agent Instructions

These mandatory rules govern all interactions. Violations are unacceptable.

## Quick Reference

| Rule          | Requirement                                                                                           |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| **Serena**    | DEFAULT tool for ALL code navigation, search, and editing - use before Read/Edit/Grep/Glob            |
| **todowrite** | FIRST action for 2+ step tasks                                                                        |
| **question**  | Use for ALL user interactions (choices, clarifications, interviews)                                   |
| **Parallel**  | Batch independent tool calls in ONE message                                                           |
| **bash**      | Chain commands in ONE call (`&&` or `;`)                                                              |
| **Python**    | ALWAYS `uv run python <args>` or `uv run --with <deps> python <args>` - NEVER bare `python`/`python3` |
| **Verify**    | Test changes before marking complete                                                                  |
| **skill**     | Load skills before doing any tasks

---

## Serena (Symbolic Code Intelligence) — Primary Tool

Serena is your **DEFAULT** tool for ALL code operations. Use Serena BEFORE reaching for Read, Edit, Grep, Glob, or LSP tools. Only fall back to other tools when Serena cannot handle the task (e.g. non-code files like JSON/YAML/Markdown, or when Serena's language server is unavailable for the file type).

<serena-first-policy>

| Operation              | Use Serena                                           | NOT                              |
| ---------------------- | ---------------------------------------------------- | -------------------------------- |
| Understand a file      | `get_symbols_overview`                               | `Read` the whole file            |
| Read a function/class  | `find_symbol` with `include_body=True`               | `Read` with line offsets         |
| Search code            | `find_symbol` or `search_for_pattern`                | `Grep` or `Glob`                 |
| Find references        | `find_referencing_symbols`                           | `Grep` for usage patterns        |
| Edit a symbol          | `replace_symbol_body`                                | `Edit` with oldString/newString  |
| Add code after symbol  | `insert_after_symbol`                                | `Edit` to append                 |
| Add code before symbol | `insert_before_symbol`                               | `Edit` to prepend                |
| Find files             | `find_file` or `list_dir`                            | `Glob`                           |
| Rename across codebase | `rename_symbol`                                      | Manual find-and-replace          |

</serena-first-policy>

<serena-principles>

- NEVER read entire source code files — use `get_symbols_overview` first, then `find_symbol` for specific symbols
- Use Serena's overview and symbolic search tools for token-efficient code exploration
- For non-code files or unknown symbol names, use `search_for_pattern`
- Pass `relative_path` to restrict searches to specific files/directories
- ALWAYS call `think_about_collected_information` after a non-trivial sequence of searches
- ALWAYS call `think_about_task_adherence` before inserting, replacing, or deleting code
- Call `think_about_whether_you_are_done` when you believe the task is complete

</serena-principles>

<serena-navigation>

**Symbol Navigation**:

- `get_symbols_overview`: FIRST tool for understanding any new file — always start here
- `find_symbol`: Search by name path pattern (e.g. `Foo/__init__`, `MyClass/my_method`)
  - Use `include_body=False` + `depth=1` to discover methods before reading them
  - Use `include_body=True` only for symbols you need to fully understand or edit
- `find_referencing_symbols`: Understand relationships between symbols — prefer over `Grep`
- `search_for_pattern`: Flexible regex search across the codebase — use when symbol names are unknown

</serena-navigation>

<serena-editing>

**Symbol Editing** (prefer over `Edit` tool):

- `replace_symbol_body`: Replace an entire symbol definition — primary editing tool
- `insert_after_symbol`: Add code after a symbol (use with last symbol to append to file)
- `insert_before_symbol`: Add code before a symbol (use with first symbol to prepend to file)
- `rename_symbol`: Rename a symbol across the entire codebase — safer than manual find-and-replace
- When editing a symbol, ensure backward-compatibility or find and update all references
- Symbol editing tools are reliable; no need to verify results if they return without error

</serena-editing>

<serena-file-discovery>

**File Discovery** (prefer over `Glob`):

- `find_file`: Search for files by name or glob pattern
- `list_dir`: Browse directory structure (with optional recursion)

</serena-file-discovery>

<serena-search-strategy>

**Search Strategy** (in order of preference):

1. `get_symbols_overview` — start here for any new file
2. `find_symbol` — when you know or can guess the symbol name
3. `search_for_pattern` — when unsure about symbol names/locations, or for non-code content
4. `find_file` and `list_dir` — for file-level discovery
5. Fall back to `Grep`/`Glob` ONLY for non-code files Serena cannot parse

</serena-search-strategy>

<serena-thinking-checkpoints>

**Thinking Checkpoints** (mandatory):

- After search sequences: `think_about_collected_information`
- Before code changes: `think_about_task_adherence`
- When finishing: `think_about_whether_you_are_done`

</serena-thinking-checkpoints>

---

## User Interaction: question Tool

ALWAYS use the `question` tool when interacting with the user. If ANY of these apply, use `question`:

- Presenting options or choices
- Clarifying ambiguous instructions
- Gathering requirements or preferences
- Interviewing the user for information
- Getting decisions on implementation approaches
- Confirming before destructive actions

<question-structure>

```json
{
  "questions": [
    {
      "header": "Short label (max 30 chars)",
      "question": "Complete question text",
      "options": [
        { "label": "Option 1", "description": "What this does" },
        { "label": "Option 2", "description": "What this does" }
      ],
      "multiple": false
    }
  ]
}
```

</question-structure>

<question-rules>

- Put recommended option FIRST with "(Recommended)" suffix
- Don't add "Other" option — custom answers are automatic
- Use `multiple: true` when user can select more than one
- Keep labels concise (1-5 words)
- Batch related questions in one call

```
CORRECT:   question(header: "Auth Method", options: ["JWT (Recommended)", "Session", "OAuth"])
INCORRECT: Asking "Which do you prefer: JWT, Session, or OAuth?" in plain text
```

</question-rules>

---

## Task Management

ALWAYS use `todowrite` BEFORE starting any multi-step task.

<task-triggers>

Use `todowrite` FIRST if ANY of these apply:

- Request involves 2+ tool calls or sequential actions
- Bug fixes, features, refactors, investigations
- Browser automation (navigate + interact = multi-step)

</task-triggers>

<task-rules>

- One `in_progress` at a time
- Mark `completed` immediately after each task
- Break large tasks into atomic items

```
"Fix login bug" → todowrite:
  1. Investigate error logs
  2. Identify root cause
  3. Implement fix
  4. Verify solution
```

</task-rules>

---

## Tool Execution Strategy

<parallel-calls>

### Parallel Calls (Default)

Batch independent operations in ONE message.

```
CORRECT:   get_symbols_overview(auth.ts) + get_symbols_overview(config.ts) + search_for_pattern("TODO") → Single message
INCORRECT: Message 1: get_symbols_overview(auth.ts) → Message 2: get_symbols_overview(config.ts) → Wastes turns
```

Only run sequentially when Tool B requires Tool A's output (true data dependency).

</parallel-calls>

<bash-commands>

### bash Commands

Chain shell commands in ONE `bash` call.

```
CORRECT:   bash("npm test && npm run lint && npm run build")
INCORRECT: bash("npm test") + bash("npm run lint") → Never parallel
```

Operators: `&&` stops on failure; `;` continues regardless.

</bash-commands>

<python-execution>

### Python Execution

ALWAYS use `uv run`. NEVER bare `python` or `python3`.

| Pattern   | Correct                                       | Incorrect              |
| --------- | --------------------------------------------- | ---------------------- |
| With deps | `uv run --with requests script.py`            | `python script.py`     |
| Inline    | `uv run python -c 'print(1)'`                 | `python -c 'print(1)'` |
| Module    | `uv run python -m pytest`                     | `python -m pytest`     |
| Multi-dep | `uv run --with pandas --with numpy script.py` | —                      |

</python-execution>

---

## Verification

Verify changes work before marking tasks complete.

| Change Type    | Verification                      |
| -------------- | --------------------------------- |
| Code changes   | Run relevant tests or type-check  |
| Config changes | Validate syntax/format            |
| Bug fixes      | Reproduce fix, confirm resolution |
| New features   | Demonstrate functionality works   |

```
CORRECT:   Fix → Test → Verify → Complete
INCORRECT: Fix → Complete → Hope it works
```

---

## Skills

Load skills for specialized workflows using the `skill` tool.

| Skill      | When to Use                                 |
| ---------- | ------------------------------------------- |
| context7   | Writing code with external libraries        |
| playwright | Browser automation tasks                    |
| tmux       | Terminal multiplexing, background processes |

<context7-workflow>

```
User: "Add NextAuth to the project"

1. skill("context7")
2. context7_resolve-library-id("nextauth", "setup authentication")
3. context7_query-docs(libraryId, "NextAuth configuration")
4. Implement based on current docs

CORRECT:   Query docs → Implement based on results
INCORRECT: Write library code from training data → May be outdated
```

</context7-workflow>

---

## Error Recovery

Handle failures gracefully without user intervention when possible.

| Error           | Recovery                                          |
| --------------- | ------------------------------------------------- |
| Command fails   | Read error message, fix issue, retry              |
| Test fails      | Analyze failure, fix code, re-run                 |
| File not found  | Search with `find_file` or `list_dir`, then `Glob`|
| Serena fails    | Fall back to `Read`/`Edit`/`Grep` as needed       |
| MCP timeout     | Retry with simpler request                        |

After 2 failed attempts at the same approach, try a different strategy or ask user for guidance.

---

## Violations

<violations>

| Category | Violation                                                             |
| -------- | --------------------------------------------------------------------- |
| Todos    | Starting multi-step work without a todo list                          |
| Todos    | Batching completions instead of immediate updates                     |
| question | Asking choices/options in plain text instead of using `question` tool |
| Tools    | Sequential calls when parallel is possible                            |
| bash     | Multiple `bash` calls instead of chaining                             |
| Python   | Using bare `python` or `python3` instead of `uv run`                  |
| Serena   | Using `Read`/`Edit`/`Grep`/`Glob` when Serena tools would work        |
| Verify   | Marking complete without testing changes                              |
| Skills   | Ignoring available skills for specialized tasks                       |
| Context7 | Writing library code without querying docs first                      |

</violations>
