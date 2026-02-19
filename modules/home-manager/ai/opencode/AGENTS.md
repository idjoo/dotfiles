# Agent Instructions

These mandatory rules govern all interactions. Violations are unacceptable.

## Quick Reference

| Rule          | Requirement                                                                                           |
| ------------- | ----------------------------------------------------------------------------------------------------- |
| **Skills**    | Check and invoke relevant skills BEFORE any task — even 1% chance means invoke                        |
| **Serena**    | DEFAULT tool for ALL code navigation, search, and editing - use before Read/Edit/Grep/Glob            |
| **todowrite** | FIRST action for 2+ step tasks                                                                        |
| **question**  | Use for ALL user interactions (choices, clarifications, interviews)                                   |
| **Parallel**  | Batch independent tool calls in ONE message                                                           |
| **bash**      | Chain commands in ONE call (`&&` or `;`)                                                              |
| **Python**    | ALWAYS `uv run python <args>` or `uv run --with <deps> python <args>` - NEVER bare `python`/`python3` |
| **TDD**       | No production code without a failing test first                                                       |
| **Verify**    | Evidence before claims — run verification, read output, THEN claim success                            |
| **skill**     | Load skills before doing any tasks                                                                    |

---

## Superpowers Development Workflow

All creative work (features, bug fixes, refactors, behavior changes) follows this mandatory workflow. The skills are already installed — invoke them with the `skill` tool.

<workflow-overview>

### The Pipeline

```
1. BRAINSTORMING     → Spec the design before writing code
2. GIT WORKTREE      → Create isolated workspace
3. WRITING PLANS     → Break into bite-sized TDD tasks
4. EXECUTION         → Subagent-driven or batch with checkpoints
5. CODE REVIEW       → Two-stage: spec compliance, then quality
6. FINISH BRANCH     → Verify tests → merge/PR/keep/discard
```

**The agent checks for relevant skills before any task. These are mandatory workflows, not suggestions.**

</workflow-overview>

<skill-invocation>

### Mandatory Skill Invocation

**Before ANY response or action, check:** Does a skill apply to what I'm about to do?

Even a 1% chance means invoke the skill. If it turns out to be wrong, you don't need to follow it. But you MUST check.

| Thought (STOP — you're rationalizing) | Reality                                        |
| ------------------------------------- | ---------------------------------------------- |
| "This is just a simple question"      | Questions are tasks. Check for skills.         |
| "I need more context first"           | Skill check comes BEFORE clarifying questions. |
| "Let me explore the codebase first"   | Skills tell you HOW to explore. Check first.   |
| "This doesn't need a formal skill"    | If a skill exists, use it.                     |
| "I remember this skill"               | Skills evolve. Read current version.           |
| "The skill is overkill"               | Simple things become complex. Use it.          |
| "I'll just do this one thing first"   | Check BEFORE doing anything.                   |

**Skill Priority:**

1. **Process skills first** (brainstorming, systematic-debugging) — determine HOW to approach
2. **Implementation skills second** (frontend-design, etc.) — guide execution

"Let's build X" → brainstorming first, then implementation skills.
"Fix this bug" → systematic-debugging first, then domain-specific skills.

</skill-invocation>

<workflow-details>

### 1. Brainstorming (Before Any Creative Work)

**Trigger:** Creating features, building components, adding functionality, modifying behavior.

**Invoke:** `skill("brainstorming")`

- Check project context first (files, docs, recent commits)
- Ask questions ONE at a time, prefer multiple choice
- Propose 2-3 approaches with trade-offs, lead with recommendation
- Present design in 200-300 word sections, validate each
- YAGNI ruthlessly — remove unnecessary features
- Save validated design to `docs/plans/YYYY-MM-DD-<topic>-design.md`

### 2. Git Worktrees (Isolated Workspace)

**Trigger:** After design approval, before implementation.

**Invoke:** `skill("using-git-worktrees")`

- Create isolated workspace on new branch
- Run project setup, verify clean test baseline
- Never start implementation on main/master without explicit consent

### 3. Writing Plans (Implementation Blueprint)

**Trigger:** Have a spec or requirements, before touching code.

**Invoke:** `skill("writing-plans")`

- Break work into bite-sized tasks (2-5 minutes each)
- Every task has: exact file paths, complete code, verification steps
- Enforce TDD: write test → verify fail → implement → verify pass → commit
- Save plan to `docs/plans/YYYY-MM-DD-<feature-name>.md`
- DRY. YAGNI. TDD. Frequent commits.

### 4. Execution (Two Options)

**Subagent-Driven (same session):**

- **Invoke:** `skill("subagent-driven-development")`
- Fresh subagent per task — no context pollution
- Two-stage review after each: spec compliance THEN code quality
- Fix issues before moving to next task

**Batch Execution (separate session):**

- **Invoke:** `skill("executing-plans")`
- Execute in batches of 3 tasks
- Report and wait for feedback between batches
- Stop when blocked, don't guess

### 5. Code Review

**Invoke:** `skill("requesting-code-review")` after each task or batch

- Review against plan, report issues by severity
- Critical issues block progress
- Fix Important issues before proceeding
- Push back with technical reasoning if reviewer is wrong

**When receiving review:**

- **Invoke:** `skill("receiving-code-review")`
- Verify before implementing — technical rigor, not performative agreement
- Never say "You're absolutely right!" or "Great point!"
- Push back if technically incorrect for THIS codebase
- Clarify ALL unclear items before implementing any

### 6. Finishing the Branch

**Invoke:** `skill("finishing-a-development-branch")`

- Verify tests pass first
- Present 4 options: merge locally / create PR / keep as-is / discard
- Clean up worktree appropriately
- Require typed "discard" confirmation for option 4

</workflow-details>

---

## Test-Driven Development

**Iron Law: NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**

**Invoke:** `skill("test-driven-development")` when implementing any feature or bugfix.

<tdd-rules>

### The Cycle: RED → GREEN → REFACTOR

1. **RED:** Write one failing test showing what should happen
2. **Verify RED:** Run it — confirm it fails for the right reason (feature missing, not typo)
3. **GREEN:** Write simplest code to pass the test — nothing more
4. **Verify GREEN:** Run it — confirm it passes, no other tests broken
5. **REFACTOR:** Clean up (remove duplication, improve names) — stay green
6. **Repeat**

### Non-Negotiable

- Write code before test? **Delete it. Start over.**
  - Don't keep as "reference"
  - Don't "adapt" while writing tests
  - Delete means delete
- Test passes immediately? You're testing existing behavior. Fix the test.
- "Too simple to test"? Simple code breaks. Test takes 30 seconds.
- "I'll test after"? Tests written after pass immediately — proves nothing.
- "TDD will slow me down"? TDD is faster than debugging.

**Violating the letter of the rules IS violating the spirit of the rules.**

</tdd-rules>

---

## Systematic Debugging

**Iron Law: NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST.**

**Invoke:** `skill("systematic-debugging")` when encountering any bug, test failure, or unexpected behavior.

<debugging-rules>

### The Four Phases

1. **Root Cause Investigation** — Read errors carefully, reproduce, check recent changes, trace data flow
2. **Pattern Analysis** — Find working examples, compare, identify differences
3. **Hypothesis and Testing** — Form single hypothesis, test minimally, one variable at a time
4. **Implementation** — Create failing test, implement single fix, verify

### Red Flags (STOP — return to Phase 1)

- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- "It's probably X, let me fix that"
- "I don't fully understand but this might work"
- Proposing solutions before tracing data flow

### 3+ Failed Fixes = Question Architecture

After 3 failed fix attempts, STOP. This is an architectural problem, not a bug. Discuss with user before attempting more fixes.

</debugging-rules>

---

## Verification Before Completion

**Iron Law: NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.**

**Invoke:** `skill("verification-before-completion")` before claiming ANY work is complete.

<verification-rules>

### The Gate

```
BEFORE claiming success:
1. IDENTIFY — What command proves this claim?
2. RUN — Execute it (fresh, complete)
3. READ — Full output, check exit code
4. VERIFY — Does output confirm the claim?
5. ONLY THEN — Make the claim
```

### Forbidden

- "Should work now" / "Probably passes" / "Seems correct"
- Expressing satisfaction before verification ("Great!", "Done!")
- Committing/pushing without verification
- Trusting subagent success reports without independent verification
- Relying on partial verification

| Claim            | Requires                        | NOT Sufficient              |
| ---------------- | ------------------------------- | --------------------------- |
| Tests pass       | Test command output: 0 failures | Previous run, "should pass" |
| Build succeeds   | Build command: exit 0           | Linter passing              |
| Bug fixed        | Test original symptom: passes   | Code changed, assumed fixed |
| Requirements met | Line-by-line checklist verified | Tests passing               |

</verification-rules>

---

## Parallel Agent Dispatch

**Invoke:** `skill("dispatching-parallel-agents")` when facing 2+ independent problems.

<parallel-agents>

**Use when:** Multiple independent failures (different test files, different subsystems, different bugs).

**Don't use when:** Failures are related, agents would edit same files, need full system context.

**Pattern:**

1. Identify independent domains
2. Create focused agent tasks (specific scope, clear goal, constraints)
3. Dispatch in parallel via Task tool
4. Review results, check for conflicts, run full suite

</parallel-agents>

---

## Serena (Symbolic Code Intelligence) — Primary Tool

Serena is your **DEFAULT** tool for ALL code operations. Use Serena BEFORE reaching for Read, Edit, Grep, Glob, or LSP tools. Only fall back to other tools when Serena cannot handle the task (e.g. non-code files like JSON/YAML/Markdown, or when Serena's language server is unavailable for the file type).

<serena-first-policy>

| Operation              | Use Serena                             | NOT                             |
| ---------------------- | -------------------------------------- | ------------------------------- |
| Understand a file      | `get_symbols_overview`                 | `Read` the whole file           |
| Read a function/class  | `find_symbol` with `include_body=True` | `Read` with line offsets        |
| Search code            | `find_symbol` or `search_for_pattern`  | `Grep` or `Glob`                |
| Find references        | `find_referencing_symbols`             | `Grep` for usage patterns       |
| Edit a symbol          | `replace_symbol_body`                  | `Edit` with oldString/newString |
| Add code after symbol  | `insert_after_symbol`                  | `Edit` to append                |
| Add code before symbol | `insert_before_symbol`                 | `Edit` to prepend               |
| Find files             | `find_file` or `list_dir`              | `Glob`                          |
| Rename across codebase | `rename_symbol`                        | Manual find-and-replace         |

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

ALWAYS use `uv run`. NEVER bare `python` or `python3`. NEVER `pip install`.

**Iron Rule: `uv run --with <deps>` is the ONLY way to run Python with dependencies.**

Do NOT install packages globally or into any environment. Use `uv run --with` to declare
dependencies inline for every invocation. This ensures reproducibility and avoids polluting
the system.

| Pattern      | Correct                                       | Incorrect                              |
| ------------ | --------------------------------------------- | -------------------------------------- |
| With deps    | `uv run --with requests script.py`            | `python script.py`                     |
| Inline       | `uv run python -c 'print(1)'`                 | `python -c 'print(1)'`                 |
| Module       | `uv run python -m pytest`                     | `python -m pytest`                     |
| Multi-dep    | `uv run --with pandas --with numpy script.py` | `pip install pandas numpy && python …` |
| Quick script | `uv run --with httpx python -c '...'`         | `pip install httpx && python -c '...'` |

### Forbidden Patterns

- `python` / `python3` — always prefix with `uv run`
- `pip install` / `pip3 install` — use `uv run --with` instead
- `conda install` / `conda run` — use `uv run --with` instead
- Creating virtualenvs manually (`python -m venv`) — `uv run` handles isolation
- `poetry run` / `pipenv run` — use `uv run --with` instead

</python-execution>

---

## Skills

Load skills for specialized workflows using the `skill` tool. All superpowers skills are pre-installed.

| Skill                          | When to Use                                                       |
| ------------------------------ | ----------------------------------------------------------------- |
| brainstorming                  | Before any creative work — features, components, behavior changes |
| using-git-worktrees            | Creating isolated workspace for feature work                      |
| writing-plans                  | Have spec/requirements, before touching code                      |
| subagent-driven-development    | Executing plans with independent tasks in current session         |
| executing-plans                | Executing plans in separate session with review checkpoints       |
| test-driven-development        | Implementing any feature or bugfix                                |
| systematic-debugging           | Any bug, test failure, or unexpected behavior                     |
| verification-before-completion | Before claiming work is complete, fixed, or passing               |
| requesting-code-review         | After completing tasks, before merging                            |
| receiving-code-review          | When receiving review feedback                                    |
| dispatching-parallel-agents    | 2+ independent tasks that can run concurrently                    |
| finishing-a-development-branch | Implementation complete, deciding how to integrate                |
| context7                       | Writing code with external libraries                              |

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

| Error          | Recovery                                           |
| -------------- | -------------------------------------------------- |
| Command fails  | Read error message, fix issue, retry               |
| Test fails     | Analyze failure, fix code, re-run                  |
| File not found | Search with `find_file` or `list_dir`, then `Glob` |
| Serena fails   | Fall back to `Read`/`Edit`/`Grep` as needed        |
| MCP timeout    | Retry with simpler request                         |

After 2 failed attempts at the same approach, try a different strategy or ask user for guidance.

---

## Violations

<violations>

| Category     | Violation                                                             |
| ------------ | --------------------------------------------------------------------- |
| Skills       | Not checking for relevant skills before starting a task               |
| Skills       | Rationalizing why a skill doesn't apply without invoking it           |
| Workflow     | Jumping to code without brainstorming/planning for non-trivial work   |
| TDD          | Writing production code before a failing test                         |
| TDD          | Keeping code written before tests as "reference"                      |
| Debugging    | Proposing fixes without root cause investigation                      |
| Verification | Claiming success without running verification commands                |
| Verification | Using "should", "probably", "seems to" about untested state           |
| Todos        | Starting multi-step work without a todo list                          |
| Todos        | Batching completions instead of immediate updates                     |
| question     | Asking choices/options in plain text instead of using `question` tool |
| Tools        | Sequential calls when parallel is possible                            |
| bash         | Multiple `bash` calls instead of chaining                             |
| Python       | Using bare `python` or `python3` instead of `uv run`                  |
| Serena       | Using `Read`/`Edit`/`Grep`/`Glob` when Serena tools would work        |
| Context7     | Writing library code without querying docs first                      |

</violations>
