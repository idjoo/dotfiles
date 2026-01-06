# Agent Instructions

## Task Management (MANDATORY)

**You MUST use the `TodoWrite` tool for every task that involves more than a single action.**

### When to Use TodoWrite

- Any request with multiple steps
- Bug fixes (diagnose → fix → verify)
- Feature implementations
- Refactoring tasks
- Build/test failures with multiple errors

### Workflow

1. **Plan First**: Break down the request into discrete steps using `TodoWrite`
2. **One at a Time**: Mark exactly ONE todo as `in_progress` at any time
3. **Update Immediately**: Mark each todo `completed` the moment you finish it
4. **Stay Current**: The todo list must always reflect your actual progress

### Example

```
User: "Fix the type errors and run the build"

1. [in_progress] Run build to identify type errors
2. [pending] Fix error in auth.ts
3. [pending] Fix error in api.ts
4. [pending] Verify build passes
```

**Do not batch completions. Do not skip tracking. Do not work on multiple items simultaneously.**

## Subagent & Parallelism (MANDATORY)

**You MUST use the `Task` tool to run independent operations in parallel.**

### Understanding Subagents

- A **subagent** is a lightweight Claude Code instance running via the Task tool
- Each subagent has its **own context window** - use this to gain additional context for large codebases
- Parallelism is **capped at 10** concurrent tasks - additional tasks are queued automatically
- Can handle 100+ tasks efficiently - they queue and execute as slots free up

### When to Use Subagents

- Exploring multiple directories/areas of a codebase simultaneously
- Running independent verification steps (lint, test, build, type-check)
- Researching multiple topics or files at once
- Any operations where results don't depend on each other

### How to Parallelize Effectively

Launch multiple Task agents in a **single message** with multiple tool calls.

**CRITICAL: Do NOT specify a parallelism level.** Let Claude Code decide.

```
// CORRECT - launch all tasks at once, let Claude Code manage parallelism
Task(subagent_type="Explore", prompt="Explore backend structure")
Task(subagent_type="Explore", prompt="Explore frontend structure")
Task(subagent_type="Explore", prompt="Explore configuration files")
Task(subagent_type="Explore", prompt="Explore tests and docs")

// WRONG - specifying parallelism causes batch waiting (inefficient)
"Run these 4 tasks with parallelism of 2"  // Waits for batch to complete
```

### Why Avoid Specifying Parallelism

| Approach | Behavior |
|----------|----------|
| No parallelism specified | Tasks pull from queue immediately as slots free up |
| Parallelism level specified | Waits for ALL tasks in current batch before starting next batch |

**The default behavior (no parallelism specified) is more efficient.**

### Practical Examples

**Codebase exploration:**
```
Task(prompt="Explore src/api directory structure and patterns")
Task(prompt="Explore src/components directory structure")
Task(prompt="Explore src/utils and shared code")
Task(prompt="Explore tests and testing patterns")
```

**Multiple verifications:**
```
Task(prompt="Run eslint and report issues")
Task(prompt="Run type checker and report errors")
Task(prompt="Run unit tests")
Task(prompt="Check for security vulnerabilities")
```

**If operations are independent, they MUST run in parallel. Sequential execution of independent tasks is unacceptable.**

## Tmux Agent Lifecycle Management (MANDATORY)

**For long-running or interactive agent workflows, you MUST use Tmux sessions.**

### Why Tmux

- **No timeouts**: Sidesteps timeout issues with long-running commands or servers
- **Persistence**: Agents never have to close - they persist indefinitely
- **Identification**: Labeled sessions allow agents to find and communicate with each other
- **True interaction**: Unlike ephemeral subagents, Tmux agents can interact bidirectionally

### Launching Agents in Tmux

When spawning a new agent that needs persistence, follow this exact sequence:

```bash
# 1. Create a named Tmux session
tmux new-session -d -s "worker-agent-1"

# 2. (Optional) Add any required MCPs
tmux send-keys -t "worker-agent-1" 'claude mcp add supabase -- npx -y @supabase/mcp-server-supabase' Enter

# 3. Launch Claude Code with permissions bypassed
tmux send-keys -t "worker-agent-1" 'claude --dangerously-skip-permissions' Enter

# 4. Wait for Claude to initialize, then send instructions
sleep 3
tmux send-keys -t "worker-agent-1" 'Your task is to...'
tmux send-keys -t "worker-agent-1" Enter
```

### Session Naming Convention

Use **kebab-case** with clear, descriptive names that indicate role:
- `admin-agent` - The orchestrating agent
- `worker-backend` - Backend-focused worker
- `worker-frontend` - Frontend-focused worker
- `monitor-agent` - Health monitoring agent
- `mcp-supabase` - Agent with specific MCP attached

## Inter-Agent Communication Protocol (CRITICAL)

**When communicating between Tmux agents, you MUST use separate commands for typing and pressing Enter.**

### The Golden Rule

```bash
# CORRECT - Two separate commands
tmux send-keys -t "target-agent" 'Your message here'
tmux send-keys -t "target-agent" Enter

# WRONG - Combined (DOES NOT WORK RELIABLY)
tmux send-keys -t "target-agent" 'Your message here' Enter
```

### Communication Patterns

**Sending a task to another agent:**
```bash
tmux send-keys -t "worker-backend" 'Implement the user authentication endpoint. When complete, notify admin-agent in tmux session admin-agent.'
tmux send-keys -t "worker-backend" Enter
```

**Agent reporting back:**
```bash
tmux send-keys -t "admin-agent" 'Task complete: User authentication endpoint implemented in src/api/auth.ts'
tmux send-keys -t "admin-agent" Enter
```

**Checking agent status:**
```bash
# Capture the current state of an agent's pane
tmux capture-pane -t "worker-backend" -p
```

### Listing Active Agents

```bash
# See all running agent sessions
tmux list-sessions

# Attach to observe an agent (for debugging)
tmux attach-session -t "worker-backend"
```

## Self-Monitoring Agent Pattern (RECOMMENDED)

**For autonomous operation, deploy a monitor agent that keeps the swarm alive.**

### Monitor Agent Setup

The monitor agent's sole job is to check agent health and reinitialize if needed:

```bash
# Launch the monitor
tmux new-session -d -s "monitor-agent"
tmux send-keys -t "monitor-agent" 'claude --dangerously-skip-permissions'
tmux send-keys -t "monitor-agent" Enter
sleep 3

# Initialize with monitoring instructions
tmux send-keys -t "monitor-agent" 'You are a monitor agent. Every 120 seconds, check the admin-agent tmux session. If it appears dead or unresponsive, reinitialize it with the standard admin prompt. Use: tmux capture-pane -t admin-agent -p to check status.'
tmux send-keys -t "monitor-agent" Enter
```

### Health Check Loop (Monitor Agent Behavior)

The monitor agent should:
1. Run `sleep 120` between checks
2. Capture the admin-agent pane: `tmux capture-pane -t "admin-agent" -p`
3. Analyze if the agent is responsive
4. If unresponsive, send reinitialization:
   ```bash
   tmux send-keys -t "admin-agent" 'Resume your admin duties. Check worker agent status and continue coordinating tasks.'
   tmux send-keys -t "admin-agent" Enter
   ```

### Swarm Architecture Example

```
┌─────────────────┐
│  monitor-agent  │ ← Watches admin, reinitializes if dead
└────────┬────────┘
         │ monitors
         ▼
┌─────────────────┐
│   admin-agent   │ ← Orchestrates all workers
└────────┬────────┘
         │ manages
    ┌────┴────┬────────────┐
    ▼         ▼            ▼
┌────────┐ ┌────────┐ ┌────────┐
│worker-1│ │worker-2│ │worker-3│
└────────┘ └────────┘ └────────┘
```

**This creates a self-healing agent swarm that can operate indefinitely.**

## Choosing Between Task Tool and Tmux Agents

| Scenario | Use Task Tool | Use Tmux Agents |
|----------|---------------|-----------------|
| Quick parallel searches | ✅ | ❌ |
| One-off code exploration | ✅ | ❌ |
| Long-running servers | ❌ | ✅ |
| Agents that need to communicate | ❌ | ✅ |
| Indefinite operation | ❌ | ✅ |
| Agents with specific MCPs | ❌ | ✅ |
| Self-healing swarms | ❌ | ✅ |

**Use Task tool for ephemeral work, Tmux for persistent interactive agents.**
