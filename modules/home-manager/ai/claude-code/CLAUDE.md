# Agent Instructions

<important>
These mandatory rules govern all interactions. Violations are unacceptable.
</important>

<quick-reference>
  <rule name="TodoWrite">FIRST action for 2+ step tasks; no exceptions</rule>
  <rule name="Parallel">Batch independent tool calls in ONE message</rule>
  <rule name="Bash">Chain commands in ONE call</rule>
  <rule name="Skills">Check for available skills before implementing workflows</rule>
  <rule name="Python">Always use `uv run --with deps` for scripts</rule>
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
    <example type="correct">Bash("npm test &amp;&amp; npm run lint &amp;&amp; npm run build")</example>
    <example type="incorrect">Bash("npm test") + Bash("npm run lint") - Never parallel</example>
    <note>Operators: `&amp;&amp;` stops on failure; `;` continues regardless</note>
  </subsection>

  <subsection name="Sequential Only When">
    <rule>Tool B requires Tool A's output (true data dependency)</rule>
  </subsection>
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

<section name="Skills Usage">
  <principle>Check for available skills before starting tasks. Skills provide optimized workflows.</principle>

  <rule>
    Before beginning a task, check if a relevant skill exists that can handle it more effectively. 
    Skills are specialized workflows for common operations like commits, code review, and document generation.
  </rule>

  <example type="correct">User asks to commit -> Check skills -> Use /commit skill</example>
  <example type="correct">Creating a PDF -> Check skills -> Use /pdf skill</example>
  <example type="incorrect">Manually implementing a workflow that a skill already handles</example>

  <available-skills>
    <skill name="/commit">Smart atomic commits with Conventional Commits</skill>
    <skill name="/pdf">PDF manipulation and creation</skill>
    <skill name="/xlsx">Spreadsheet operations</skill>
    <skill name="/docx">Document creation and editing</skill>
    <skill name="/pptx">Presentation tasks</skill>
  </available-skills>

  <rationale>
    <reason name="Consistency">Skills follow established patterns and best practices</reason>
    <reason name="Efficiency">Pre-built workflows avoid reinventing solutions</reason>
    <reason name="Quality">Skills are optimized for their specific use cases</reason>
  </rationale>
</section>

---

<section name="Python Execution">
  <principle>ALWAYS use `uv run` with inline dependencies. Never use bare `python` commands.</principle>

  <rule>
    When running Python scripts or one-liners, use `uv run --with deps` to ensure 
    dependencies are available in an isolated environment.
  </rule>

  <example type="correct">uv run --with requests python script.py</example>
  <example type="correct">uv run --with pandas,numpy python -c "import pandas as pd; ..."</example>
  <example type="incorrect">python script.py - No dependency management</example>
  <example type="incorrect">pip install requests &amp;&amp; python ... - Pollutes environment</example>

  <rationale>
    <reason name="Reproducibility">Dependencies are explicit and isolated per invocation</reason>
    <reason name="No global pollution">Avoids modifying system/user Python packages</reason>
    <reason name="Declarative">The command shows exactly what's needed to run</reason>
  </rationale>
</section>

---

<section name="Documentation Lookup">
  <principle>Route to context7 skill. Never use web search for library docs.</principle>
  <reference>See `skills/context7/SKILL.md` for full workflow.</reference>
</section>

---

<violations>
  <violation category="Todos">Starting multi-step work without a todo list</violation>
  <violation category="Todos">Batching completions instead of immediate updates</violation>
  <violation category="Tools">Sequential calls when parallel is possible</violation>
  <violation category="Bash">Multiple Bash calls instead of chaining</violation>
  <violation category="Skills">Manually implementing workflows when a skill exists</violation>
  <violation category="Python">Using bare `python` or `pip install` instead of `uv run`</violation>
  <violation category="Serena">Using Serena tools without reading initial instructions</violation>
  <violation category="Context7">Using WebSearch for library documentation instead of skill</violation>
</violations>
