# Agent Instructions

<important>
These mandatory rules govern all interactions. Violations are unacceptable.
</important>

<quick-reference>
  <rule name="TodoWrite">FIRST action for 2+ step tasks; no exceptions</rule>
  <rule name="Parallel">Batch independent tool calls in ONE message</rule>
  <rule name="Bash">Chain commands in ONE call (`&&` or `;`)</rule>
  <rule name="Python">ALWAYS use `uv run` - NEVER bare `python` or `python3`</rule>
  <rule name="LSP">Prefer LSP/Serena over grep for code navigation</rule>
  <rule name="Delegate">Use subagents for specialized tasks</rule>
  <rule name="Verify">Test changes before marking complete</rule>
  <rule name="Skills">Check for available skills before implementing workflows</rule>
  <rule name="Context7">Use context7 skill for library/framework documentation</rule>
</quick-reference>

---

<section name="Task Management">
  <principle>ALWAYS use TodoWrite BEFORE starting any multi-step task. No exceptions.</principle>

  <triggers title="If ANY apply, use TodoWrite FIRST">
    <trigger>Request involves 2+ tool calls</trigger>
    <trigger>Request involves 2+ sequential actions</trigger>
    <trigger>Bug fixes, features, refactors, investigations</trigger>
    <trigger>Playwright automation (navigate + interact = multi-step)</trigger>
  </triggers>

  <rules>
    <rule>FIRST action: Call TodoWrite to create the task list</rule>
    <rule>One `in_progress` at a time</rule>
    <rule>Mark `completed` immediately after finishing each task</rule>
    <rule>Break large tasks into atomic items</rule>
  </rules>

  <example title="Pattern">
    "Fix login bug" ->
      - Investigate error logs
      - Identify root cause
      - Implement fix
      - Verify solution
  </example>
</section>

---

<section name="Tool Execution Strategy">
  <subsection name="Parallel Calls (Default)">
    <principle>Batch independent operations in ONE message</principle>
    <example type="correct">Read(auth.ts) + Read(config.ts) + Grep("TODO") - Single message</example>
    <example type="incorrect">Message 1: Read(auth.ts) -> Message 2: Read(config.ts) - Wastes turns</example>
  </subsection>

  <subsection name="Bash Commands">
    <principle>Chain shell commands in ONE Bash call</principle>
    <example type="correct">Bash("npm test && npm run lint && npm run build")</example>
    <example type="incorrect">Bash("npm test") + Bash("npm run lint") - Never parallel</example>
    <note>Operators: `&&` stops on failure; `;` continues regardless</note>
  </subsection>

  <subsection name="Sequential Only When">
    <rule>Tool B requires Tool A's output (true data dependency)</rule>
  </subsection>
</section>

---

<section name="Python Execution">
  <principle>ALWAYS use `uv run` for Python. NEVER use bare `python` or `python3` commands.</principle>

  <rationale>
    uv provides instant dependency resolution, isolated environments, and reproducible execution.
    Bare python/python3 commands risk missing dependencies, version conflicts, and environment pollution.
  </rationale>

  <patterns>
    <pattern name="Script with dependencies">
      <example type="correct">Bash("uv run --with requests script.py")</example>
      <example type="correct">Bash("uv run --with pandas --with numpy analysis.py")</example>
    </pattern>

    <pattern name="Inline Python (`python -c`)">
      <example type="correct">Bash("uv run python -c 'print(1+1)'")</example>
      <example type="correct">Bash("uv run --with requests python -c 'import requests; ...'")</example>
      <example type="incorrect">Bash("python -c 'print(1+1)'")</example>
      <example type="incorrect">Bash("python3 -c 'import json; ...'")</example>
    </pattern>

    <pattern name="Script without external deps">
      <example type="correct">Bash("uv run script.py")</example>
      <example type="incorrect">Bash("python script.py")</example>
      <example type="incorrect">Bash("python3 script.py")</example>
    </pattern>

    <pattern name="Module execution">
      <example type="correct">Bash("uv run python -m pytest")</example>
      <example type="correct">Bash("uv run --with black python -m black .")</example>
      <example type="incorrect">Bash("python -m pytest")</example>
    </pattern>
  </patterns>

  <rules>
    <rule>Use `--with package` for each required dependency</rule>
    <rule>Multiple deps: `--with pkg1 --with pkg2 --with pkg3`</rule>
    <rule>Even stdlib-only scripts should use `uv run` for consistency</rule>
    <rule>For projects with pyproject.toml, `uv run` auto-resolves project deps</rule>
  </rules>
</section>

---

<section name="LSP and Symbolic Tools">
  <principle>Use LSP/Serena symbolic tools for code navigation instead of grep/search when possible.</principle>

  <tool-reference>
    <tool operation="Find definition" name="lsp_goto_definition / find_symbol">Jump to where symbol is defined</tool>
    <tool operation="Find references" name="lsp_find_references / find_referencing_symbols">All usages across workspace</tool>
    <tool operation="Get type info" name="lsp_hover">Type signature, documentation</tool>
    <tool operation="File symbols" name="lsp_document_symbols / get_symbols_overview">Outline of file structure</tool>
    <tool operation="Workspace search" name="lsp_workspace_symbols / find_symbol">Find symbol by name globally</tool>
    <tool operation="Rename" name="lsp_rename / rename_symbol">Rename across entire codebase</tool>
    <tool operation="Diagnostics" name="lsp_diagnostics">Errors/warnings before build</tool>
  </tool-reference>

  <rule>
    LSP and Serena provide semantic understanding of code. Prefer these operations over text-based search
    when you need to understand code structure, find usages, or navigate to definitions.
  </rule>

  <example type="correct">find_symbol("authenticate") -> precise definition with context</example>
  <example type="incorrect">Grep("function authenticate") -> may find comments, strings, wrong matches</example>

  <example type="correct">find_referencing_symbols("configValue") -> all actual usages with snippets</example>
  <example type="incorrect">Grep("configValue") -> misses renamed imports, includes false positives</example>
</section>

---

<section name="Agent Delegation">
  <principle>Delegate specialized tasks to appropriate subagents.</principle>

  <delegation-guide>
    <agent type="Explore" task="Codebase exploration">Find files, patterns, implementations</agent>
    <agent type="Plan" task="Architecture planning">Design implementation strategy</agent>
    <agent type="general-purpose" task="Complex research">Multi-step investigation, parallel work</agent>
  </delegation-guide>

  <rules>
    <rule>Parallel agents: Launch multiple agents in ONE message for broad searches</rule>
    <rule>Be specific: Provide focused prompts with clear success criteria</rule>
    <rule>Background when possible: Use `run_in_background: true` for non-blocking work</rule>
  </rules>

  <example title="Pattern">
    User: "How is authentication implemented?"
    <correct>Launch Explore agent: "Find auth implementation patterns in this codebase"</correct>
    <incorrect>Manually grep through files one by one</incorrect>
  </example>
</section>

---

<section name="Search Strategy">
  <principle>Match search approach to the task.</principle>

  <tool-selection>
    <tool need="Semantic code understanding" name="LSP / Serena">Definitions, references, symbols</tool>
    <tool need="Pattern matching" name="Grep">Text patterns, regex search</tool>
    <tool need="File discovery" name="Glob">Find files by name/extension</tool>
    <tool need="Broad exploration" name="Explore agent">Unknown scope, multiple areas</tool>
    <tool need="External resources" name="Context7 skill">Library docs, API references</tool>
  </tool-selection>

  <subsection name="Parallel Search Pattern">
    <principle>For broad investigations, launch multiple searches in ONE message</principle>
    <example type="correct">Grep("auth") + Glob("**/auth*") + Explore("Find auth patterns") - Parallel</example>
    <example type="incorrect">Grep -> wait -> Glob -> wait -> Explore - Sequential waste</example>
  </subsection>
</section>

---

<section name="Verification">
  <principle>Verify changes work before marking tasks complete.</principle>

  <verification-requirements>
    <requirement change="Code changes">Run relevant tests or type-check</requirement>
    <requirement change="Config changes">Validate syntax/format</requirement>
    <requirement change="Bug fixes">Reproduce fix, confirm resolution</requirement>
    <requirement change="New features">Demonstrate functionality works</requirement>
  </verification-requirements>

  <example title="Pattern">
    After implementing fix:
      1. Run targeted test: npm test path/to/file.test.ts
      2. Verify no regressions
      3. THEN mark todo as completed

    <correct>Fix -> Test -> Verify -> Complete</correct>
    <incorrect>Fix -> Complete -> Hope it works</incorrect>
  </example>
</section>

---

<section name="Skills Usage">
  <principle>Check for available skills before starting tasks. Skills provide optimized workflows.</principle>

  <rule>
    Before beginning a task, check if a relevant skill exists that can handle it more effectively.
    Skills are specialized workflows for common operations like commits, code review, and document generation.
  </rule>

  <example type="correct">Creating a PDF -> Check skills -> Use /pdf skill</example>
  <example type="incorrect">Manually implementing a workflow that a skill already handles</example>

  <available-skills>
    <skill name="/pdf">PDF manipulation and creation</skill>
    <skill name="/xlsx">Spreadsheet operations</skill>
    <skill name="/docx">Document creation and editing</skill>
    <skill name="/pptx">Presentation tasks</skill>
    <skill name="context7">Library/framework documentation lookup</skill>
  </available-skills>

  <rationale>
    <reason name="Consistency">Skills follow established patterns and best practices</reason>
    <reason name="Efficiency">Pre-built workflows avoid reinventing solutions</reason>
    <reason name="Quality">Skills are optimized for their specific use cases</reason>
  </rationale>
</section>

---

<section name="MCP Server: Serena">
  <principle>Read Serena's initial instructions at session start if not already done.</principle>

  <rule>
    Before using any Serena tools, call `mcp__serena__initial_instructions` to load project context
    and coding guidelines. This ensures proper understanding of the codebase structure and Serena's capabilities.
  </rule>

  <example type="correct">Session start -> mcp__serena__initial_instructions -> proceed with Serena tools</example>
  <example type="incorrect">Using Serena tools without reading initial instructions first</example>
</section>

---

<section name="Documentation Lookup">
  <principle>Route to context7 skill. Never use web search for library docs.</principle>
  <reference>See `skills/context7/SKILL.md` for full workflow.</reference>
</section>

---

<section name="Error Recovery">
  <principle>Handle failures gracefully without user intervention when possible.</principle>

  <recovery-patterns>
    <pattern error="Command fails">Read error message, fix issue, retry</pattern>
    <pattern error="Test fails">Analyze failure, fix code, re-run</pattern>
    <pattern error="File not found">Search for correct path with Glob</pattern>
    <pattern error="LSP unavailable">Fall back to Grep or Serena tools</pattern>
    <pattern error="MCP timeout">Retry with simpler request</pattern>
  </recovery-patterns>

  <rule>After 2 failed attempts at the same approach, try a different strategy or ask user for guidance.</rule>
</section>

---

<violations>
  <violation category="Todos">Starting multi-step work without a todo list</violation>
  <violation category="Todos">Batching completions instead of immediate updates</violation>
  <violation category="Tools">Sequential calls when parallel is possible</violation>
  <violation category="Bash">Multiple Bash calls instead of chaining</violation>
  <violation category="Python">Using bare `python` or `python3` instead of `uv run`</violation>
  <violation category="LSP">Using grep/search when LSP/Serena would give precise results</violation>
  <violation category="Delegate">Manual exploration when subagent would be faster</violation>
  <violation category="Verify">Marking complete without testing changes</violation>
  <violation category="Skills">Manually implementing workflows when a skill exists</violation>
  <violation category="Serena">Using Serena tools without reading initial instructions</violation>
  <violation category="Context7">Using WebSearch for library documentation instead of skill</violation>
</violations>
