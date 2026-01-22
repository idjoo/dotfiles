# Agent Instructions

<important>
These mandatory rules govern all interactions. Violations are unacceptable.
</important>

<quick-reference>
  <rule name="todowrite">FIRST action for 2+ step tasks; no exceptions</rule>
  <rule name="Parallel">Batch independent tool calls in ONE message</rule>
  <rule name="Bash">Chain commands in ONE call (`&amp;&amp;` or `;`)</rule>
  <rule name="LSP">Prefer LSP over grep for code navigation</rule>
  <rule name="Delegate">Use subagents for specialized tasks</rule>
  <rule name="Verify">Test changes before marking complete</rule>
  <rule name="Skills">Load skills (Context7, Playwright) when needed</rule>
</quick-reference>

---

<section name="Task Management">
  <principle>ALWAYS use todowrite BEFORE starting any multi-step task. No exceptions.</principle>

  <triggers title="If ANY apply, use todowrite FIRST">
    <trigger>Request involves 2+ tool calls</trigger>
    <trigger>Request involves 2+ sequential actions</trigger>
    <trigger>Bug fixes, features, refactors, investigations</trigger>
    <trigger>Playwright automation (navigate + interact = multi-step)</trigger>
  </triggers>

  <rules>
    <rule>FIRST action: Call todowrite to create the task list</rule>
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
    <example type="correct">Bash("npm test &amp;&amp; npm run lint &amp;&amp; npm run build")</example>
    <example type="incorrect">Bash("npm test") + Bash("npm run lint") - Never parallel</example>
    <note>Operators: `&amp;&amp;` stops on failure; `;` continues regardless</note>
  </subsection>

  <subsection name="Sequential Only When">
    <rule>Tool B requires Tool A's output (true data dependency)</rule>
  </subsection>
</section>

---

<section name="LSP Tools">
  <principle>Use LSP tools for code navigation instead of grep/search when possible.</principle>

  <tool-reference>
    <tool operation="Find definition" name="lsp_goto_definition">Jump to where symbol is defined</tool>
    <tool operation="Find references" name="lsp_find_references">All usages across workspace</tool>
    <tool operation="Get type info" name="lsp_hover">Type signature, documentation</tool>
    <tool operation="File symbols" name="lsp_document_symbols">Outline of file structure</tool>
    <tool operation="Workspace search" name="lsp_workspace_symbols">Find symbol by name globally</tool>
    <tool operation="Rename" name="lsp_rename">Rename across entire codebase</tool>
    <tool operation="Diagnostics" name="lsp_diagnostics">Errors/warnings before build</tool>
  </tool-reference>

  <rule>
    LSP provides semantic understanding of code. Prefer LSP operations over text-based search 
    when you need to understand code structure, find usages, or navigate to definitions.
  </rule>

  <example type="correct">lsp_goto_definition("auth.ts", 42, 15) -> precise definition location</example>
  <example type="incorrect">Grep("function authenticate") -> may find comments, strings, wrong matches</example>

  <example type="correct">lsp_find_references("config.ts", 10, 8) -> all actual usages</example>
  <example type="incorrect">Grep("configValue") -> misses renamed imports, includes false positives</example>

  <requirements>
    LSP servers must be configured for the file type. Built-in servers auto-start for: 
    TypeScript, Python, Go, Rust, C/C++, Java, and many more.
  </requirements>
</section>

---

<section name="Agent Delegation">
  <principle>Delegate specialized tasks to appropriate subagents.</principle>

  <delegation-guide>
    <agent type="explore" task="Codebase exploration">Find files, patterns, implementations</agent>
    <agent type="librarian" task="External docs/repos">Library docs, GitHub examples, remote repos</agent>
    <agent type="general" task="Complex research">Multi-step investigation, parallel work</agent>
    <agent type="oracle" task="Architecture decisions">Design guidance, deep code analysis</agent>
  </delegation-guide>

  <rules>
    <rule>Parallel agents: Launch multiple explore/librarian agents in ONE message for broad searches</rule>
    <rule>Be specific: Provide focused prompts with clear success criteria</rule>
    <rule>Background when possible: Use `run_in_background: true` for non-blocking work</rule>
  </rules>

  <example title="Pattern">
    User: "How is authentication implemented?"
    <correct>Launch explore agent: "Find auth implementation patterns in this codebase"</correct>
    <incorrect>Manually grep through files one by one</incorrect>
  </example>
</section>

---

<section name="Search Strategy">
  <principle>Match search approach to the task.</principle>

  <tool-selection>
    <tool need="Semantic code understanding" name="LSP">Definitions, references, symbols</tool>
    <tool need="Pattern matching" name="Grep / AST-grep">Text patterns, code structures</tool>
    <tool need="File discovery" name="Glob">Find files by name/extension</tool>
    <tool need="Broad exploration" name="explore agent">Unknown scope, multiple areas</tool>
    <tool need="External resources" name="librarian agent">Docs, remote repos, examples</tool>
  </tool-selection>

  <subsection name="Parallel Search Pattern">
    <principle>For broad investigations, launch multiple searches in ONE message</principle>
    <example type="correct">Grep("auth") + Glob("**/auth*") + explore("Find auth patterns") - Parallel</example>
    <example type="incorrect">Grep -> wait -> Glob -> wait -> explore - Sequential waste</example>
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

<section name="Skills">
  <principle>Load skills for specialized workflows using the `skill` tool.</principle>

  <available-skills>
    <skill name="context7">Writing code with external libraries</skill>
    <skill name="playwright">Browser automation tasks</skill>
    <skill name="tmux">Terminal multiplexing, background processes</skill>
  </available-skills>

  <subsection name="Context7 Workflow">
    <example>
      User: "Add NextAuth to the project"

      1. skill("context7") - Load documentation skill
      2. context7_resolve-library-id("nextauth", "setup authentication")
      3. context7_query-docs(libraryId, "NextAuth configuration")
      4. Implement based on current docs

      <correct>Query docs -> Implement based on results</correct>
      <incorrect>Write library code from training data - May be outdated</incorrect>
    </example>
  </subsection>
</section>

---

<section name="MCP Server: Serena">
  <principle>Read Serena's initial instructions at session start if not already done.</principle>

  <rule>
    Before using any Serena tools, call `serena_initial_instructions` to load project context. 
    This ensures proper understanding of the codebase structure.
  </rule>

  <example type="correct">Session start -> serena_initial_instructions -> proceed with Serena tools</example>
  <example type="incorrect">Using Serena tools without reading initial instructions first</example>
</section>

---

<section name="Error Recovery">
  <principle>Handle failures gracefully without user intervention when possible.</principle>

  <recovery-patterns>
    <pattern error="Command fails">Read error message, fix issue, retry</pattern>
    <pattern error="Test fails">Analyze failure, fix code, re-run</pattern>
    <pattern error="File not found">Search for correct path with Glob</pattern>
    <pattern error="LSP unavailable">Fall back to Grep/AST-grep</pattern>
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
  <violation category="LSP">Using grep/search when LSP would give precise results</violation>
  <violation category="Delegate">Manual exploration when subagent would be faster</violation>
  <violation category="Verify">Marking complete without testing changes</violation>
  <violation category="Skills">Ignoring available skills for specialized tasks</violation>
  <violation category="Serena">Using Serena tools without reading initial instructions</violation>
  <violation category="Context7">Writing library code without querying docs first</violation>
</violations>
